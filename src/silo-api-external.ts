#!/usr/bin/env bun
/**
 * silo-api-external - External API server
 * 
 * Port: 3000
 * Purpose: Minimal surface for remote agent control
 * Security: Auth required, verb allowlist
 */

import { Hono } from 'hono'
import { streamSSE } from 'hono/streaming'
import { spawn } from 'node:child_process'
import { readFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'
import { getAuthConfig, createAuthMiddleware, logApiCall } from './lib/auth.ts'
import { loadAllowlistConfig, isVerbAllowed } from './lib/verb-allowlist.ts'

// Config
const PORT = parseInt(process.env.SILO_API_PORT || '3000')
const SILO_DIR = process.env.SILO_DIR || process.cwd()
const HOST = process.env.SILO_API_HOST || '0.0.0.0'

// Auth & allowlist
const authConfig = getAuthConfig()
const allowlistConfig = loadAllowlistConfig(SILO_DIR)

// Hono app
const app = new Hono()

// Apply auth middleware to all routes
app.use('*', createAuthMiddleware(authConfig))

// ============================================
// HELPERS
// ============================================

function getSiloManifest() {
  const siloPath = join(SILO_DIR, '.silo')
  if (!existsSync(siloPath)) return null
  try {
    return JSON.parse(readFileSync(siloPath, 'utf-8'))
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

// ============================================
// ROUTES: Minimal Surface
// ============================================

/**
 * GET /health - Liveness check (no auth required)
 */
app.get('/health', (c) => {
  logApiCall(authConfig, '/health', c.req.header('cf-connecting-ip') || 'unknown')
  return c.json({ status: 'ok', server: 'external' })
})

/**
 * GET /status - Current silo state
 */
app.get('/status', async (c) => {
  logApiCall(authConfig, '/status', c.req.header('cf-connecting-ip') || 'unknown')
  
  const statusPath = join(SILO_DIR, 'status.json')
  if (existsSync(statusPath)) {
    try {
      return c.json(JSON.parse(readFileSync(statusPath, 'utf-8')))
    } catch { /* fall through */ }
  }
  
  return c.json({
    state: 'idle',
    lastUpdate: new Date().toISOString()
  })
})

/**
 * GET /verbs - List allowed verbs (only remote-enabled)
 */
app.get('/verbs', async (c) => {
  logApiCall(authConfig, '/verbs', c.req.header('cf-connecting-ip') || 'unknown')
  
  const verbs = await getVerbs()
  const allowedVerbs = verbs.filter(v => 
    isVerbAllowed(v, allowlistConfig.allowed, allowlistConfig.allowAll)
  )
  
  return c.json({ 
    verbs: allowedVerbs,
    total: allowedVerbs.length,
    allowAll: allowlistConfig.allowAll
  })
})

/**
 * GET /verbs/:verb - Help for specific verb
 */
app.get('/verbs/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  // Check allowlist
  if (!isVerbAllowed(verb, allowlistConfig.allowed, allowlistConfig.allowAll)) {
    return c.json({ error: `Verb '${verb}' is not allowed for remote execution` }, 403)
  }
  
  const help = await getRecipeHelp(verb)
  return c.json({ verb, help })
})

/**
 * POST /exec/:verb - Execute verb (SSE streaming)
 */
app.post('/exec/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  logApiCall(authConfig, `/exec/${verb}`, c.req.header('cf-connecting-ip') || 'unknown')
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  // Check allowlist
  if (!isVerbAllowed(verb, allowlistConfig.allowed, allowlistConfig.allowAll)) {
    return c.json({ error: `Verb '${verb}' is not allowed for remote execution` }, 403)
  }
  
  const body = await c.req.json().catch(() => ({}))
  const args: string[] = body.args || []
  const signal = c.req.raw.signal
  
  return streamSSE(c, async (stream) => {
    const proc = spawn('just', [verb, ...args], { cwd: SILO_DIR })
    
    // Kill process on client disconnect
    const cleanup = () => {
      if (!proc.killed) {
        proc.kill('SIGTERM')
        stream.writeSSE({ data: 'Terminated by client disconnect', event: 'terminate' })
      }
    }
    
    // Handle abort signal
    signal.addEventListener('abort', cleanup)
    
    proc.stdout.on('data', (data) => {
      stream.writeSSE({ data: data.toString(), event: 'stdout' })
    })
    
    proc.stderr.on('data', (data) => {
      stream.writeSSE({ data: data.toString(), event: 'stderr' })
    })
    
    proc.on('close', (code) => {
      signal.removeEventListener('abort', cleanup)
      stream.writeSSE({ data: `Exit code: ${code}`, event: 'close' })
      stream.close()
    })
    
    proc.on('error', (err) => {
      signal.removeEventListener('abort', cleanup)
      stream.writeSSE({ data: err.message, event: 'error' })
      stream.close()
    })
  })
})

/**
 * POST /exec-sync/:verb - Execute verb (synchronous)
 */
app.post('/exec-sync/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  if (!isVerbAllowed(verb, allowlistConfig.allowed, allowlistConfig.allowAll)) {
    return c.json({ error: `Verb '${verb}' is not allowed for remote execution` }, 403)
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
      logApiCall(authConfig, `/exec-sync/${verb}`, c.req.header('cf-connecting-ip') || 'unknown')
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
║   silo-api-external (v2)                    ║
║   Remote agent control                       ║
╚═══════════════════════════════════════════════╝
Silo:     ${SILO_DIR}
Port:      ${PORT}
Auth:      ${authConfig.enabled ? 'enabled (' + authConfig.headerName + ')' : 'disabled'}
Allowlist: ${allowlistConfig.allowAll ? 'all verbs' : allowlistConfig.allowed.size + ' verbs'}
`)

export default {
  port: PORT,
  hostname: HOST,
  fetch: app.fetch
}
