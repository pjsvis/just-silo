/**
 * Verb allowlist parser
 * 
 * Parses justfile for recipes marked as `remote="true"`
 * These recipes can be executed via the external API.
 */

import { readFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'

export interface VerbMetadata {
  name: string
  description?: string
  remote: boolean
  params?: string[]
}

export interface AllowlistConfig {
  allowAll: boolean  // If true, no remote annotation needed
  allowed: Set<string>
  denied: Set<string>
}

/**
 * Parse justfile for remote="true" annotations
 * 
 * Format: recipe-name param1 param2: [remote="true"]
 */
export function parseRemoteVerbs(justfilePath: string): Set<string> {
  if (!existsSync(justfilePath)) {
    return new Set()
  }
  
  const content = readFileSync(justfilePath, 'utf-8')
  const remoteVerbs = new Set<string>()
  
  // Match lines like: `recipe-name:` or `recipe-name arg: [remote="true"]`
  const recipePattern = /^([a-zA-Z0-9_-]+)\s*(?:[^\s:]+)?:(?:\s*#.*)?\s*\[remote="true"\]/gm
  
  let match
  while ((match = recipePattern.exec(content)) !== null) {
    remoteVerbs.add(match[1])
  }
  
  // Also match inline: `recipe: [remote="true"]`
  const inlinePattern = /^([a-zA-Z0-9_-]+):\s*#.*\[remote="true"\]/gm
  while ((match = inlinePattern.exec(content)) !== null) {
    remoteVerbs.add(match[1])
  }
  
  return remoteVerbs
}

/**
 * Check if a verb is allowed for remote execution
 */
export function isVerbAllowed(
  verb: string, 
  allowedVerbs: Set<string>,
  allowAll: boolean = false
): boolean {
  if (allowAll) return true
  return allowedVerbs.has(verb)
}

/**
 * Get all verbs with their metadata
 */
export async function getVerbMetadata(siloDir: string): Promise<VerbMetadata[]> {
  const justfilePath = join(siloDir, 'justfile')
  const allowedVerbs = parseRemoteVerbs(justfilePath)
  
  // Get all verbs from just --summary
  const { spawn } = await import('node:child_process')
  
  return new Promise((resolve) => {
    const proc = spawn('just', ['--summary'], { cwd: siloDir })
    let output = ''
    
    proc.stdout.on('data', (data) => { output += data.toString() })
    proc.on('close', () => {
      const verbs = output.split(/\s+/)
        .map(v => v.trim())
        .filter(v => v.length > 0)
        .map(v => v.split('#')[0].trim())
        .filter(v => v.length > 0)
      
      const metadata: VerbMetadata[] = verbs.map(name => ({
        name,
        remote: allowedVerbs.has(name)
      }))
      
      resolve(metadata)
    })
    proc.on('error', () => resolve([]))
  })
}

/**
 * Load allowlist config from environment or justfile
 */
export function loadAllowlistConfig(siloDir: string): AllowlistConfig {
  const allowAll = process.env.SILO_ALLOW_ALL === 'true'
  const allowedVerbs = parseRemoteVerbs(join(siloDir, 'justfile'))
  
  return {
    allowAll,
    allowed: allowedVerbs,
    denied: new Set()
  }
}
