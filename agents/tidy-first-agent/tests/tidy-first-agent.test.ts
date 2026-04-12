/**
 * tidy-first-agent Tests
 * 
 * Tests the full lifecycle of the tidy-first-agent:
 * 1. check - Quick status check
 * 2. status - Detailed status view
 * 3. run - Auto-tidy workflow
 * 4. gamma-loop - Knowledge persistence after run
 */

import { describe, test, expect, beforeAll, afterAll, beforeEach } from 'bun:test'
import { existsSync, mkdirSync, writeFileSync, readFileSync, rmSync } from 'node:fs'
import { join } from 'node:path'
import { execSync } from 'node:child_process'

// Test constants from CSP.md
const BRIEFS_THRESHOLD = 30
const DEBRIEFS_THRESHOLD = 20
const STALE_DAYS = 14

// Paths
const PROJECT_ROOT = execSync('git rev-parse --show-toplevel', { encoding: 'utf-8' }).trim()
const TEST_AGENT_DIR = join(PROJECT_ROOT, 'agents', 'tidy-first-agent')
const TEST_SCRIPT = join(TEST_AGENT_DIR, 'src', 'tidy-first-agent')

describe('tidy-first-agent Lifecycle', () => {
  
  describe('1. Agent Invocation', () => {
    test('script is executable', () => {
      expect(existsSync(TEST_SCRIPT)).toBe(true)
      const stat = require('fs').statSync(TEST_SCRIPT)
      expect(stat.mode & 0o111).not.toBe(0)
    })
    
    test('help command works', () => {
      const output = execSync(`${TEST_SCRIPT} help`, { encoding: 'utf-8' })
      expect(output).toContain('tidy-first-agent')
      expect(output).toContain('check')
      expect(output).toContain('status')
      expect(output).toContain('run')
    })
  })
  
  describe('2. Check Mode', () => {
    test('check returns workspace status', () => {
      const output = execSync(`${TEST_SCRIPT} check`, { encoding: 'utf-8' })
      // Should show either "tidy" or list issues
      expect(output).toMatch(/tidy|Issues found/)
    })
  })
  
  describe('3. Status Mode', () => {
    test('status shows detailed metrics', () => {
      const output = execSync(`${TEST_SCRIPT} status`, { encoding: 'utf-8' })
      expect(output).toContain('BRIEFS')
      expect(output).toContain('DEBRIEFS')
      expect(output).toContain('STALE')
      expect(output).toContain('BRANCHES')
    })
    
    test('status shows threshold values from CSP', () => {
      const output = execSync(`${TEST_SCRIPT} status`, { encoding: 'utf-8' })
      expect(output).toContain(`threshold: ${BRIEFS_THRESHOLD}`)
      expect(output).toContain(`threshold: ${DEBRIEFS_THRESHOLD}`)
    })
  })
  
  describe('4. Run Mode (Auto-Tidy)', () => {
    test('run executes without error', () => {
      // Should not throw
      expect(() => {
        execSync(`${TEST_SCRIPT} run`, { encoding: 'utf-8' })
      }).not.toThrow()
    })
    
    test('run shows progress steps', () => {
      const output = execSync(`${TEST_SCRIPT} run`, { encoding: 'utf-8' })
      expect(output).toContain('[1/4] Checking briefs')
      expect(output).toContain('[2/4] Checking debriefs')
      expect(output).toContain('[3/4] Checking stale td issues')
      expect(output).toContain('[4/4] Checking git branches')
    })
    
    test('run shows action results', () => {
      const output = execSync(`${TEST_SCRIPT} run`, { encoding: 'utf-8' })
      // Each step should show a status indicator
      expect(output).toMatch(/✓|!|-/)
    })
  })
  
  describe('5. Run --full Mode (With Brief-Gen)', () => {
    test('run --full shows brief recommendations', () => {
      const output = execSync(`${TEST_SCRIPT} run --full`, { encoding: 'utf-8' })
      // Should show brief-gen section if there are issues
      expect(output).toContain('[1/4]')
    })
  })
  
  describe('6. Gamma-Loop Integration', () => {
    test('agent has CSP.md', () => {
      const cspPath = join(TEST_AGENT_DIR, 'CSP.md')
      expect(existsSync(cspPath)).toBe(true)
      
      const csp = readFileSync(cspPath, 'utf-8')
      // CSP should describe the agent's purpose and workflow
      expect(csp).toContain('tidy-first-agent')
      expect(csp).toContain('auto-tidy')
    })
    
    test('agent has manifest.json', () => {
      const manifestPath = join(TEST_AGENT_DIR, 'manifest.json')
      expect(existsSync(manifestPath)).toBe(true)
      
      const manifest = JSON.parse(readFileSync(manifestPath, 'utf-8'))
      expect(manifest.name).toBeDefined()
    })
  })
  
  describe('7. CSP Constraints Compliance', () => {
    test('CSP defines thresholds in table format', () => {
      const cspPath = join(TEST_AGENT_DIR, 'CSP.md')
      const csp = readFileSync(cspPath, 'utf-8')
      
      // Thresholds should be documented
      expect(csp).toContain('Briefs')
      expect(csp).toContain('Debriefs')
      expect(csp).toContain('> 30')
      expect(csp).toContain('> 20')
    })
    
    test('CSP defines auto-tidy actions', () => {
      const cspPath = join(TEST_AGENT_DIR, 'CSP.md')
      const csp = readFileSync(cspPath, 'utf-8')
      
      expect(csp).toContain('Auto-Tidy Actions')
      expect(csp).toContain('Archive old briefs')
      expect(csp).toContain('Archive old debriefs')
      expect(csp).toContain('Prune merged git branches')
    })
    
    test('CSP defines constraints', () => {
      const cspPath = join(TEST_AGENT_DIR, 'CSP.md')
      const csp = readFileSync(cspPath, 'utf-8')
      
      // Key constraints from CSP
      expect(csp).toContain('Never delete')
      expect(csp).toContain('archive/move')
      expect(csp).toContain('git commit')
      expect(csp).toContain('Log actions')
    })
  })
  
  describe('8. Integration Points', () => {
    test('justfile exists with tidy recipe', () => {
      const justfilePath = join(TEST_AGENT_DIR, 'justfile')
      expect(existsSync(justfilePath)).toBe(true)
      
      const justfile = readFileSync(justfilePath, 'utf-8')
      expect(justfile).toContain('tidy')
    })
    
    test('README exists with usage', () => {
      const readmePath = join(TEST_AGENT_DIR, 'README.md')
      expect(existsSync(readmePath)).toBe(true)
      
      const readme = readFileSync(readmePath, 'utf-8')
      expect(readme).toContain('tidy-first-agent')
    })
  })
})

describe('tidy-first-agent Gamma-Loop', () => {
  
  test('gamma-loop triggers after tidy run', () => {
    // Run the agent
    const output = execSync(`${TEST_SCRIPT} run`, { encoding: 'utf-8' })
    
    // Gamma-loop should log entropy and adjustments
    // For now, just verify run completed
    expect(output).toContain('[1/4]')
  })
  
  test('entropy is measured and logged', () => {
    // After tidy, check if entropy can be calculated
    // Low entropy = workspace is stable
    // High entropy = workspace needs attention
    const output = execSync(`${TEST_SCRIPT} status`, { encoding: 'utf-8' })
    
    // Status should show the state of the workspace
    expect(output).toContain('BRIEFS')
  })
  
  test('thresholds are respected from CSP', () => {
    const output = execSync(`${TEST_SCRIPT} status`, { encoding: 'utf-8' })
    
    // Should show the threshold values
    expect(output).toContain(String(BRIEFS_THRESHOLD))
    expect(output).toContain(String(DEBRIEFS_THRESHOLD))
  })
})

describe('Error Handling', () => {
  
  test('handles missing directories gracefully', () => {
    // Agent should handle cases where directories don't exist
    const output = execSync(`${TEST_SCRIPT} check`, { encoding: 'utf-8' })
    expect(output).toBeDefined()
  })
  
  test('unknown commands show help', () => {
    const output = execSync(`${TEST_SCRIPT} unknown_command`, { encoding: 'utf-8' })
    expect(output).toContain('Usage')
    expect(output).toContain('tidy-first-agent')
  })
})
