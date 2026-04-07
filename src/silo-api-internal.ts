#!/usr/bin/env bun
/**
 * silo-api-internal - Internal API server
 * 
 * Port: 3001 (localhost only)
 * Purpose: Rich development dashboard and full feature access
 * Security: localhost only, no auth required
 */

import { Hono } from 'hono'
import { streamSSE } from 'hono/streaming'
import { spawn } from 'node:child_process'
import { readFileSync, existsSync, statSync, watch } from 'node:fs'
import { join } from 'node:path'

// Types
interface SiloManifest {
  name: string
  version: string
  domain?: string
  description?: string
}

// Config
const PORT = parseInt(process.env.SILO_API_PORT || '3001')
const SILO_DIR = process.env.SILO_DIR || process.cwd()
const HOST = process.env.SILO_API_HOST || '127.0.0.1'
const STREAM_INTERVAL = parseInt(process.env.SILO_STREAM_INTERVAL || '2000')

// Hono app
const app = new Hono()

// ============================================
// HELPERS
// ============================================

function getSiloManifest(): SiloManifest | null {
  const siloPath = join(SILO_DIR, '.silo')
  if (!existsSync(siloPath)) return null
  try {
    const content = readFileSync(siloPath, 'utf-8')
    return JSON.parse(content) as SiloManifest
  } catch {
    return null
  }
}

async function getVerbs(): Promise<string[]> {
  return new Promise((resolve) => {
    const proc = spawn('just', ['--summary'], { cwd: SILO_DIR })
    let output = ''
    proc.stdout.on('data', (data) => { output += data.toString() })
    proc.on('close', () => {
      const verbs = output.split(/\s+/)
        .map(v => v.trim())
        .filter(v => v.length > 0)
        .map(v => v.split('#')[0].trim())
        .filter(v => v.length > 0)
      resolve(verbs)
    })
    proc.on('error', () => resolve([]))
  })
}

async function getRecipeHelp(verb: string): Promise<string> {
  return new Promise((resolve) => {
    const proc = spawn('just', ['help', verb], { cwd: SILO_DIR })
    let output = ''
    proc.stdout.on('data', (data) => { output += data.toString() })
    proc.on('close', () => resolve(output.trim()))
    proc.on('error', () => resolve(''))
  })
}

function readLastLine(filePath: string): string {
  try {
    const content = readFileSync(filePath, 'utf-8')
    const lines = content.trim().split('\n').filter(l => l.trim())
    return lines[lines.length - 1] || ''
  } catch {
    return ''
  }
}

function getStatus(): object {
  const statusPath = join(SILO_DIR, 'status.json')
  if (existsSync(statusPath)) {
    try {
      return JSON.parse(readFileSync(statusPath, 'utf-8'))
    } catch { /* fall through */ }
  }
  return {
    state: 'unknown',
    message: 'No status file',
    lastUpdate: new Date().toISOString()
  }
}

// ============================================
// ROUTES: Discovery
// ============================================

app.get('/health', (c) => c.json({ status: 'ok', server: 'internal', silo: SILO_DIR }))

app.get('/capabilities', async (c) => {
  const manifest = getSiloManifest()
  const verbs = await getVerbs()
  return c.json({
    silo: manifest?.name || 'unnamed',
    version: manifest?.version || '0.0.0',
    domain: manifest?.domain || 'unknown',
    verbs,
    server: 'internal'
  })
})

app.get('/manifest', (c) => {
  const manifest = getSiloManifest()
  if (!manifest) return c.json({ error: 'No .silo manifest' }, 404)
  return c.json(manifest)
})

app.get('/verbs', async (c) => {
  const verbs = await getVerbs()
  return c.json({ verbs })
})

app.get('/verbs/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  const help = await getRecipeHelp(verb)
  return c.json({ verb, help })
})

// ============================================
// ROUTES: SSE Streaming
// ============================================

app.get('/stream/status', (c) => {
  return streamSSE(c, async (stream) => {
    const statusPath = join(SILO_DIR, 'status.json')
    let lastMtime = 0
    
    while (true) {
      try {
        if (existsSync(statusPath)) {
          const stat = statSync(statusPath)
          if (stat.mtimeMs > lastMtime) {
            lastMtime = stat.mtimeMs
            await stream.writeSSE({
              data: JSON.stringify(getStatus()),
              event: 'status',
              id: String(Date.now())
            })
          }
        }
      } catch { /* ignore */ }
      await new Promise(r => setTimeout(r, STREAM_INTERVAL))
    }
  })
})

app.get('/stream/heartbeat', (c) => {
  return streamSSE(c, async (stream) => {
    const heartbeatPath = join(SILO_DIR, 'heartbeat.jsonl')
    let lastLine = ''
    
    await stream.writeSSE({
      data: JSON.stringify({ type: 'connected', silo: SILO_DIR }),
      event: 'ping'
    })
    
    while (true) {
      try {
        if (existsSync(heartbeatPath)) {
          const lastEntry = readLastLine(heartbeatPath)
          if (lastEntry && lastEntry !== lastLine) {
            lastLine = lastEntry
            await stream.writeSSE({ data: lastEntry, event: 'heartbeat' })
          }
        }
      } catch { /* ignore */ }
      await new Promise(r => setTimeout(r, STREAM_INTERVAL))
    }
  })
})

app.get('/stream/logs', (c) => {
  return streamSSE(c, async (stream) => {
    const dataPath = join(SILO_DIR, 'data.jsonl')
    let lastLine = ''
    
    await stream.writeSSE({
      data: JSON.stringify({ type: 'connected', silo: SILO_DIR }),
      event: 'ping'
    })
    
    while (true) {
      try {
        if (existsSync(dataPath)) {
          const lastEntry = readLastLine(dataPath)
          if (lastEntry && lastEntry !== lastLine) {
            lastLine = lastEntry
            await stream.writeSSE({ data: lastEntry, event: 'log' })
          }
        }
      } catch { /* ignore */ }
      await new Promise(r => setTimeout(r, STREAM_INTERVAL))
    }
  })
})

app.get('/stream/all', (c) => {
  return streamSSE(c, async (stream) => {
    const statusPath = join(SILO_DIR, 'status.json')
    const heartbeatPath = join(SILO_DIR, 'heartbeat.jsonl')
    const dataPath = join(SILO_DIR, 'data.jsonl')
    
    let lastStatusMtime = 0
    let lastHeartbeat = ''
    let lastLog = ''
    
    await stream.writeSSE({
      data: JSON.stringify({ type: 'connected', silo: SILO_DIR }),
      event: 'ping'
    })
    
    while (true) {
      try {
        if (existsSync(statusPath)) {
          const stat = statSync(statusPath)
          if (stat.mtimeMs > lastStatusMtime) {
            lastStatusMtime = stat.mtimeMs
            await stream.writeSSE({
              data: JSON.stringify({ ...getStatus(), source: 'status' }),
              event: 'status'
            })
          }
        }
        if (existsSync(heartbeatPath)) {
          const hb = readLastLine(heartbeatPath)
          if (hb && hb !== lastHeartbeat) {
            lastHeartbeat = hb
            await stream.writeSSE({ data: hb, event: 'heartbeat' })
          }
        }
        if (existsSync(dataPath)) {
          const log = readLastLine(dataPath)
          if (log && log !== lastLog) {
            lastLog = log
            await stream.writeSSE({ data: log, event: 'log' })
          }
        }
      } catch { /* ignore */ }
      await new Promise(r => setTimeout(r, STREAM_INTERVAL))
    }
  })
})

// ============================================
// ROUTES: Execution
// ============================================

app.post('/rpc/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  const body = await c.req.json().catch(() => ({}))
  const args: string[] = body.args || []
  
  return streamSSE(c, async (stream) => {
    const proc = spawn('just', [verb, ...args], { cwd: SILO_DIR })
    
    proc.stdout.on('data', (data) => {
      stream.writeSSE({ data: data.toString(), event: 'stdout' })
    })
    
    proc.stderr.on('data', (data) => {
      stream.writeSSE({ data: data.toString(), event: 'stderr' })
    })
    
    proc.on('close', (code) => {
      stream.writeSSE({ data: `Exit code: ${code}`, event: 'close' })
      stream.close()
    })
    
    proc.on('error', (err) => {
      stream.writeSSE({ data: err.message, event: 'error' })
      stream.close()
    })
  })
})

app.post('/exec/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  const body = await c.req.json().catch(() => ({}))
  const args: string[] = body.args || []
  
  return new Promise((resolve) => {
    const proc = spawn('just', [verb, ...args], { cwd: SILO_DIR })
    let stdout = ''
    let stderr = ''
    
    proc.stdout.on('data', (data) => { stdout += data.toString() })
    proc.stderr.on('data', (data) => { stderr += data.toString() })
    
    proc.on('close', (code) => {
      resolve(c.json({ verb, args, exitCode: code, stdout: stdout.trim(), stderr: stderr.trim() }))
    })
    
    proc.on('error', (err) => {
      resolve(c.json({ error: err.message }, 500))
    })
  })
})

// ============================================
// START SERVER
// ============================================

console.log(`
╔═══════════════════════════════════════════════╗
║   silo-api-internal (v2)                    ║
║   Local development dashboard                ║
╚═══════════════════════════════════════════════╝
Silo:     ${SILO_DIR}
Port:      ${PORT} (localhost only)
Host:      ${HOST}
`)

export default {
  port: PORT,
  hostname: HOST,
  fetch: app.fetch
}
