import { describe, test, expect } from 'bun:test'
import { join } from 'node:path'

const SILO_DIR = process.cwd()

describe('Auth Module', () => {
  test('getAuthConfig returns correct structure', async () => {
    const { getAuthConfig } = await import('./lib/auth.ts')
    const config = getAuthConfig()
    
    expect(config).toHaveProperty('enabled')
    expect(config).toHaveProperty('token')
    expect(config).toHaveProperty('headerName')
    expect(typeof config.enabled).toBe('boolean')
    expect(typeof config.headerName).toBe('string')
  })
})

describe('Verb Allowlist Module', () => {
  test('parseRemoteVerbs returns Set', async () => {
    const { parseRemoteVerbs } = await import('./lib/verb-allowlist.ts')
    const verbs = parseRemoteVerbs(join(SILO_DIR, 'justfile'))
    
    expect(verbs).toBeInstanceOf(Set)
  })
  
  test('isVerbAllowed respects allowlist', async () => {
    const { isVerbAllowed } = await import('./lib/verb-allowlist.ts')
    
    // With allowAll=false and empty allowlist
    expect(isVerbAllowed('help', new Set(), false)).toBe(false)
    
    // With allowAll=true
    expect(isVerbAllowed('help', new Set(), true)).toBe(true)
    
    // With verb in allowlist
    expect(isVerbAllowed('help', new Set(['help']), false)).toBe(true)
  })
  
  test('loadAllowlistConfig returns correct structure', async () => {
    const { loadAllowlistConfig } = await import('./lib/verb-allowlist.ts')
    const config = loadAllowlistConfig(SILO_DIR)
    
    expect(config).toHaveProperty('allowAll')
    expect(config).toHaveProperty('allowed')
    expect(config).toHaveProperty('denied')
    expect(config.allowed).toBeInstanceOf(Set)
    expect(config.denied).toBeInstanceOf(Set)
  })
})
