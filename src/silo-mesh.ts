#!/usr/bin/env bun
/**
 * silo-mesh - Hono facade with auto-discovery
 * 
 * Mesh node: auto-discovers silos in a directory
 * and provides unified API for all silos.
 */

import { Hono } from 'hono'
import { readdirSync, existsSync, readFileSync } from 'node:fs'
import { join, basename } from 'node:path'
import { spawn } from 'node:child_process'

const app = new Hono()

// Config
const PORT = parseInt(process.env.SILO_MESH_PORT || '3000')
const SILO_DIR = process.env.SILO_MESH_DIR || process.cwd()
const HOST = process.env.SILO_MESH_HOST || '0.0.0.0'

// Types
interface SiloNode {
  name: string
  path: string
  manifest?: {
    name: string
    version: string
    domain?: string
  }
  verbs?: string[]
  online: boolean
}

interface SiloMesh {
  meshName: string
  nodeCount: number
  silos: SiloNode[]
}

// ============================================
// DISCOVERY: Find all silos in mesh directory
// ============================================
function discoverSilos(): SiloNode[] {
  const silos: SiloNode[] = []
  
  if (!existsSync(SILO_DIR)) {
    return silos
  }
  
  try {
    const entries = readdirSync(SILO_DIR, { withFileTypes: true })
    
    for (const entry of entries) {
      if (!entry.isDirectory()) continue
      
      const siloPath = join(SILO_DIR, entry.name)
      const siloFile = join(siloPath, '.silo')
      
      if (existsSync(siloFile)) {
        try {
          const content = readFileSync(siloFile, 'utf-8')
          const manifest = JSON.parse(content)
          
          silos.push({
            name: manifest.name || entry.name,
            path: siloPath,
            manifest: {
              name: manifest.name,
              version: manifest.version,
              domain: manifest.domain
            },
            online: existsSync(join(siloPath, '.silo.local'))
          })
        } catch {
          // Invalid manifest, still add basic entry
          silos.push({
            name: entry.name,
            path: siloPath,
            online: false
          })
        }
      }
    }
  } catch {
    // Directory not readable
  }
  
  return silos
}

// ============================================
// INTROSPECTION: Get verbs for a specific silo
// ============================================
async function getSiloVerbs(siloPath: string): Promise<string[]> {
  return new Promise((resolve) => {
    const proc = spawn('just', ['--summary'], { cwd: siloPath })
    let output = ''
    
    proc.stdout.on('data', (data) => { output += data.toString() })
    proc.on('close', () => {
      const verbs = output.split(/\s+/)
        .map(v => v.trim())
        .filter(v => v.length > 0)
        .map(v => v.split('#')[0].trim())
      resolve(verbs)
    })
    proc.on('error', () => resolve([]))
  })
}

// ============================================
// EXECUTION: Run command in silo
// ============================================
async function executeInSilo(siloPath: string, verb: string, args: string[] = []): Promise<{code: number, stdout: string, stderr: string}> {
  return new Promise((resolve) => {
    const proc = spawn('just', [verb, ...args], { cwd: siloPath })
    let stdout = ''
    let stderr = ''
    
    proc.stdout.on('data', (d) => { stdout += d.toString() })
    proc.stderr.on('data', (d) => { stderr += d.toString() })
    proc.on('close', (code) => {
      resolve({ code: code || 0, stdout, stderr })
    })
    proc.on('error', (err) => {
      resolve({ code: 1, stdout: '', stderr: err.message })
    })
  })
}

// ============================================
// ROUTES
// ============================================

// Mesh overview
app.get('/mesh', async (c) => {
  const silos = discoverSilos()
  return c.json({
    meshName: basename(SILO_DIR),
    nodeCount: silos.length,
    silos: silos.map(s => ({
      name: s.name,
      domain: s.manifest?.domain,
      online: s.online
    }))
  })
})

// List all silos
app.get('/silos', async (c) => {
  const silos = discoverSilos()
  return c.json({ silos })
})

// Get specific silo info
app.get('/silos/:name', async (c) => {
  const name = c.req.param('name')
  const silos = discoverSilos()
  const silo = silos.find(s => s.name === name)
  
  if (!silo) {
    return c.json({ error: `Silo '${name}' not found` }, 404)
  }
  
  const verbs = await getSiloVerbs(silo.path)
  
  return c.json({
    ...silo,
    verbs
  })
})

// Execute in specific silo
app.post('/silos/:name/rpc/:verb', async (c) => {
  const name = c.req.param('name')
  const verb = c.req.param('verb')
  const body = await c.req.json().catch(() => ({}))
  const args: string[] = body.args || []
  
  const silos = discoverSilos()
  const silo = silos.find(s => s.name === name)
  
  if (!silo) {
    return c.json({ error: `Silo '${name}' not found` }, 404)
  }
  
  const verbs = await getSiloVerbs(silo.path)
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found in silo '${name}'` }, 404)
  }
  
  console.log(`[silo-mesh] ${name}: just ${verb} ${args.join(' ')}`)
  
  const result = await executeInSilo(silo.path, verb, args)
  return c.json(result)
})

// Execute in specific silo (sync JSON)
app.post('/silos/:name/exec/:verb', async (c) => {
  const name = c.req.param('name')
  const verb = c.req.param('verb')
  const body = await c.req.json().catch(() => ({}))
  const args: string[] = body.args || []
  
  const silos = discoverSilos()
  const silo = silos.find(s => s.name === name)
  
  if (!silo) {
    return c.json({ error: `Silo '${name}' not found` }, 404)
  }
  
  const verbs = await getSiloVerbs(silo.path)
  if (!verbs.includes(verb)) {
    return c.json({ error: `Verb '${verb}' not found` }, 404)
  }
  
  console.log(`[silo-mesh] ${name}: just ${verb} ${args.join(' ')}`)
  
  const result = await executeInSilo(silo.path, verb, args)
  return c.json({
    silo: name,
    verb,
    args,
    exitCode: result.code,
    stdout: result.stdout.trim(),
    stderr: result.stderr.trim()
  })
})

// Health check
app.get('/health', (c) => {
  const silos = discoverSilos()
  return c.json({
    status: 'ok',
    mesh: basename(SILO_DIR),
    silos: silos.length,
    online: silos.filter(s => s.online).length
  })
})

// ============================================
// START
// ============================================
console.log(`
╔═══════════════════════════════════════════╗
║   silo-mesh                             ║
║   Hono Facade with Auto-Discovery       ║
╚═══════════════════════════════════════════╝
Mesh:    ${SILO_DIR}
Port:     ${PORT}
Host:     ${HOST}
`)

export default {
  port: PORT,
  hostname: HOST,
  fetch: app.fetch
}
