#!/usr/bin/env bun
/**
 * silo-api-server - Semantic API from justfile
 * 
 * Transparent proxy: treats filesystem as logic layer.
 * - Introspection: parse justfile for verbs
 * - Mapping: dynamic routes per verb
 * - Execution: SSE stream output
 */

import { Hono } from 'hono'
import { streamSSE } from 'hono/streaming'
import { spawn } from 'node:child_process'
import { readFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'

// Types
interface Verb {
  name: string
  description?: string
  params?: string[]
}

interface SiloManifest {
  name: string
  version: string
  domain?: string
  description?: string
}

// Config
const PORT = parseInt(process.env.SILO_API_PORT || '3000')
const SILO_DIR = process.env.SILO_DIR || process.cwd()
const HOST = process.env.SILO_API_HOST || '0.0.0.0'

// Hono app
const app = new Hono()

// ============================================
// 1. DISCOVERY: Get Silo Manifest
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

// ============================================
// 2. INTROSPECTION: Parse justfile for verbs
// ============================================
async function getVerbs(): Promise<string[]> {
  return new Promise((resolve) => {
    const proc = spawn('just', ['--summary'], { cwd: SILO_DIR })
    let output = ''
    
    proc.stdout.on('data', (data) => { output += data.toString() })
    proc.stderr.on('data', () => { /* ignore */ })
    proc.on('close', () => {
      // just --summary outputs all verbs on one line, space-separated
      // Each verb may have a # comment after it
      const verbs = output.split(/\s+/)
        .map(line => line.trim())
        .filter(v => v.length > 0)
        .map(v => v.split('#')[0].trim()) // Remove comments
        .filter(v => v.length > 0)
      resolve(verbs)
    })
    proc.on('error', () => resolve([]))
  })
}

// ============================================
// 3. HELP: Get recipe help
// ============================================
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
// 4. EXECUTION: Run verb with args
// ============================================
async function executeVerb(verb: string, args: string[] = []): Promise<void> {
  return new Promise((resolve, reject) => {
    const proc = spawn('just', [verb, ...args], { cwd: SILO_DIR })
    
    proc.on('close', (code) => {
      if (code === 0) resolve()
      else reject(new Error(`Exit code: ${code}`))
    })
    proc.on('error', reject)
  })
}

// ============================================
// ROUTES
// ============================================

// Health check
app.get('/health', (c) => c.json({ status: 'ok', silo: SILO_DIR }))

// Capabilities discovery
app.get('/capabilities', async (c) => {
  const manifest = getSiloManifest()
  const verbs = await getVerbs()
  
  return c.json({
    silo: manifest?.name || 'unnamed',
    version: manifest?.version || '0.0.0',
    domain: manifest?.domain || 'unknown',
    verbs,
    endpoints: {
      verbs: '/capabilities',
      execute: '/rpc/:verb',
      health: '/health',
      manifest: '/manifest'
    }
  })
})

// Get manifest
app.get('/manifest', (c) => {
  const manifest = getSiloManifest()
  if (!manifest) return c.json({ error: 'No .silo manifest found' }, 404)
  return c.json(manifest)
})

// List verbs
app.get('/verbs', async (c) => {
  const verbs = await getVerbs()
  return c.json({ verbs })
})

// Get verb help
app.get('/verbs/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  const help = await getRecipeHelp(verb)
  return c.json({ verb, help })
})

// Execute verb via SSE
app.post('/rpc/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  const body = await c.req.json().catch(() => ({}))
  const args: string[] = body.args || []
  
  console.log(`[silo-api] Executing: just ${verb} ${args.join(' ')}`)
  
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

// Execute verb (sync, JSON response)
app.post('/exec/:verb', async (c) => {
  const verb = c.req.param('verb')
  const verbs = await getVerbs()
  
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  const body = await c.req.json().catch(() => ({}))
  const args: string[] = body.args || []
  
  console.log(`[silo-api] Executing: just ${verb} ${args.join(' ')}`)
  
  return new Promise((resolve) => {
    const proc = spawn('just', [verb, ...args], { cwd: SILO_DIR })
    let stdout = ''
    let stderr = ''
    
    proc.stdout.on('data', (data) => { stdout += data.toString() })
    proc.stderr.on('data', (data) => { stderr += data.toString() })
    
    proc.on('close', (code) => {
      resolve(c.json({ 
        verb, 
        args,
        exitCode: code,
        stdout: stdout.trim(),
        stderr: stderr.trim()
      }))
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
╔═══════════════════════════════════════════╗
║   silo-api-server                        ║
║   Semantic API for justfile              ║
╚═══════════════════════════════════════════╝
Silo:    ${SILO_DIR}
Port:     ${PORT}
Host:     ${HOST}
`)

export default {
  port: PORT,
  hostname: HOST,
  fetch: app.fetch
}
