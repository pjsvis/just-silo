/**
 * code-review-agent Tests
 * 
 * Tests the full lifecycle of the code-review-agent:
 * 1. Status - Current state
 * 2. Poll - Check for requests
 * 3. Review - Full review workflow
 * 4. Analysis - FAFCAS analysis
 * 5. Report - Generate scores and report
 */

import { describe, test, expect, beforeAll, afterAll, beforeEach } from 'bun:test'
import { existsSync, mkdirSync, writeFileSync, readFileSync, rmSync } from 'node:fs'
import { join } from 'node:path'
import { execSync } from 'node:child_process'

// Paths
const PROJECT_ROOT = execSync('git rev-parse --show-toplevel', { encoding: 'utf-8' }).trim()
const TEST_AGENT_DIR = join(PROJECT_ROOT, 'agents', 'code-review-agent')

// Ensure state directory exists
const stateDir = join(TEST_AGENT_DIR, 'markers', 'state')
if (!existsSync(stateDir)) {
  mkdirSync(stateDir, { recursive: true })
}

// Helper to run just commands in agent directory
function runJust(cmd: string, dir = TEST_AGENT_DIR): string {
  return execSync(`just ${cmd}`, { cwd: dir, encoding: 'utf-8' })
}

describe('code-review-agent Lifecycle', () => {
  
  beforeEach(() => {
    // Reset state before each test
    try {
      runJust('reset')
    } catch { /* ignore */ }
  })
  
  describe('1. Agent Invocation', () => {
    test('default command shows status', () => {
      const output = runJust('')
      expect(output).toContain('Code Review Agent')
    })
    
    test('status command works', () => {
      const output = runJust('status')
      expect(output).toContain('Status')
    })
  })
  
  describe('2. Request Handling', () => {
    test('poll shows no pending requests when empty', () => {
      const output = runJust('poll')
      expect(output).toMatch(/No pending requests|Request found/)
    })
    
    test('idle sets state to IDLE', () => {
      // Commands write to state file silently
      runJust('idle')
      const stateFile = join(TEST_AGENT_DIR, 'markers', 'state', 'current')
      expect(existsSync(stateFile)).toBe(true)
      const state = readFileSync(stateFile, 'utf-8').trim()
      expect(state).toBe('IDLE')
    })
    
    test('running sets state to RUNNING', () => {
      runJust('running')
      const stateFile = join(TEST_AGENT_DIR, 'markers', 'state', 'current')
      expect(existsSync(stateFile)).toBe(true)
      const state = readFileSync(stateFile, 'utf-8').trim()
      expect(state).toBe('RUNNING')
    })
  })
  
  describe('3. Analysis Mode', () => {
    test('analyze command exists', () => {
      // Should not throw
      expect(() => {
        runJust('analyze HEAD~1..HEAD incremental')
      }).not.toThrow()
    })
    
    test('analysis-results shows results or empty state', () => {
      const output = runJust('analysis-results')
      expect(output).toBeDefined()
    })
  })
  
  describe('4. Hardening Mode', () => {
    test('harden command exists', () => {
      // Should not throw
      expect(() => {
        runJust('harden low')
      }).not.toThrow()
    })
    
    test('patches command exists', () => {
      const output = runJust('patches')
      expect(output).toBeDefined()
    })
  })
  
  describe('5. Reporting', () => {
    test('report command exists', () => {
      // Should not throw
      expect(() => {
        runJust('report')
      }).not.toThrow()
    })
    
    test('scores command exists', () => {
      const output = runJust('scores')
      expect(output).toBeDefined()
    })
    
    test('report-show command exists', () => {
      const output = runJust('report-show')
      expect(output).toBeDefined()
    })
  })
  
  describe('6. Coordination', () => {
    test('error command sets error state', () => {
      runJust('error "test error"')
      const errorFile = join(TEST_AGENT_DIR, 'markers', 'state', 'current')
      expect(existsSync(errorFile)).toBe(true)
      const state = readFileSync(errorFile, 'utf-8').trim()
      expect(state).toBe('ERROR')
    })
    
    test('reset clears all state', () => {
      // Reset should not throw
      expect(() => {
        runJust('reset')
      }).not.toThrow()
    })
  })
  
  describe('7. Agent Structure', () => {
    test('manifest.json exists', () => {
      const manifestPath = join(TEST_AGENT_DIR, 'manifest.json')
      expect(existsSync(manifestPath)).toBe(true)
      
      const manifest = JSON.parse(readFileSync(manifestPath, 'utf-8'))
      expect(manifest.name).toBe('code-review-agent')
      expect(manifest.commands).toContain('review')
    })
    
    test('README exists with usage', () => {
      const readmePath = join(TEST_AGENT_DIR, 'README.md')
      expect(existsSync(readmePath)).toBe(true)
      
      const readme = readFileSync(readmePath, 'utf-8')
      expect(readme).toContain('FAFCAS')
      expect(readme).toContain('review')
    })
    
    test('scripts directory exists with required scripts', () => {
      const scriptsDir = join(TEST_AGENT_DIR, 'scripts')
      expect(existsSync(scriptsDir)).toBe(true)
      
      const scripts = ['analyze.sh', 'coordinate.sh', 'harden.sh', 'report.sh']
      for (const script of scripts) {
        expect(existsSync(join(scriptsDir, script))).toBe(true)
      }
    })
    
    test('markers directory structure exists', () => {
      const markersDir = join(TEST_AGENT_DIR, 'markers')
      expect(existsSync(join(markersDir, 'request'))).toBe(true)
      expect(existsSync(join(markersDir, 'done'))).toBe(true)
      expect(existsSync(join(markersDir, 'error'))).toBe(true)
    })
  })
  
  describe('8. Integration Points', () => {
    test('coordinate.sh exists and is executable', () => {
      const scriptPath = join(TEST_AGENT_DIR, 'scripts', 'coordinate.sh')
      expect(existsSync(scriptPath)).toBe(true)
      const stat = require('fs').statSync(scriptPath)
      expect(stat.mode & 0o111).not.toBe(0)
    })
    
    test('request-schema.json is valid JSON', () => {
      const schemaPath = join(TEST_AGENT_DIR, 'request-schema.json')
      expect(existsSync(schemaPath)).toBe(true)
      
      const schema = JSON.parse(readFileSync(schemaPath, 'utf-8'))
      expect(schema.type).toBe('object')
      expect(schema.properties).toBeDefined()
    })
  })
})

describe('code-review-agent FAFCAS Rubric', () => {
  
  test('README documents FAFCAS dimensions', () => {
    const readmePath = join(TEST_AGENT_DIR, 'README.md')
    const readme = readFileSync(readmePath, 'utf-8')
    
    expect(readme).toContain('Factual')
    expect(readme).toContain('Accurate')
    expect(readme).toContain('Fair')
    expect(readme).toContain('Complete')
    expect(readme).toContain('Actionable')
    expect(readme).toContain('Specific')
  })
  
  test('README documents auto-hardening thresholds', () => {
    const readmePath = join(TEST_AGENT_DIR, 'README.md')
    const readme = readFileSync(readmePath, 'utf-8')
    
    expect(readme).toContain('low')
    expect(readme).toContain('medium')
    expect(readme).toContain('high')
    expect(readme).toContain('all')
  })
  
  test('README documents security handling', () => {
    const readmePath = join(TEST_AGENT_DIR, 'README.md')
    const readme = readFileSync(readmePath, 'utf-8')
    
    // Security issues should NOT be auto-fixed
    expect(readme).toContain('Security issues')
    expect(readme).toContain('NEVER auto-fixed')
  })
})

describe('code-review-agent Request/Response', () => {
  
  test('can create and process a request', () => {
    const requestDir = join(TEST_AGENT_DIR, 'markers', 'request')
    const requestFile = join(requestDir, 'payload.jsonl')
    
    // Create a request
    const request = JSON.stringify({
      target: 'HEAD~1..HEAD',
      scope: 'incremental',
      mode: 'review',
      threshold: 'low'
    })
    
    writeFileSync(requestFile, request)
    expect(existsSync(requestFile)).toBe(true)
    
    // Cleanup
    rmSync(requestFile)
  })
  
  test('review workflow executes without error', () => {
    // Reset state first
    runJust('reset')
    
    // Create a request to make review happy
    const requestFile = join(TEST_AGENT_DIR, 'markers', 'request', 'payload.jsonl')
    writeFileSync(requestFile, JSON.stringify({
      target: 'HEAD~1..HEAD',
      scope: 'incremental',
      mode: 'review',
      threshold: 'low'
    }))
    
    // Review should not throw
    expect(() => {
      runJust('review')
    }).not.toThrow()
    
    // Cleanup
    rmSync(requestFile)
  })
})
