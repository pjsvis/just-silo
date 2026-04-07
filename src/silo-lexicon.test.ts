import { describe, expect, test, beforeAll, afterAll } from 'bun:test'
import { writeFileSync, rmSync, existsSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { execSync } from 'node:child_process'
import { tempDir, cleanupTempDir } from './test-utils'

describe('silo-lexicon', () => {
  describe('CLI script', () => {
    test('silo-lexicon script exists', () => {
      const path = join(process.cwd(), 'scripts', 'silo-lexicon')
      expect(existsSync(path)).toBe(true)
    })

    test('silo-lexicon outputs lexicon on execution', () => {
      const path = join(process.cwd(), 'scripts', 'silo-lexicon')
      const output = execSync(`bun ${path}`, { encoding: 'utf-8' })
      expect(output).toContain('Silo Lexicon')
      expect(output).toContain('stuff')
    })

    test('silo-lexicon --short outputs compact format', () => {
      const path = join(process.cwd(), 'scripts', 'silo-lexicon')
      const output = execSync(`bun ${path} --short`, { encoding: 'utf-8' })
      expect(output).toContain('**')
    })

    test('silo-lexicon --json outputs valid JSON', () => {
      const path = join(process.cwd(), 'scripts', 'silo-lexicon')
      const output = execSync(`bun ${path} --json`, { encoding: 'utf-8' })
      const parsed = JSON.parse(output)
      expect(Array.isArray(parsed)).toBe(true)
      expect(parsed.length).toBeGreaterThan(0)
    })

    test('silo-lexicon --help shows usage', () => {
      const path = join(process.cwd(), 'scripts', 'silo-lexicon')
      const output = execSync(`bun ${path} --help`, { encoding: 'utf-8' })
      expect(output).toContain('Usage')
    })

    test('silo-lexicon lookup finds known token', () => {
      const path = join(process.cwd(), 'scripts', 'silo-lexicon')
      const output = execSync(`bun ${path} "stuff"`, { encoding: 'utf-8' })
      expect(output).toContain('stuff')
      expect(output).toContain('things')
    })

    test('silo-lexicon lookup returns error for unknown token', () => {
      const path = join(process.cwd(), 'scripts', 'silo-lexicon')
      try {
        execSync(`bun ${path} "nonexistent-xyz-123"`, { encoding: 'utf-8' })
        throw new Error('Should have failed')
      } catch (e: any) {
        expect(e.status).toBe(1)
      }
    })
  })

  describe('lexicon data file', () => {
    test('silo-lexicon.jsonl exists in project root', () => {
      const path = join(process.cwd(), 'silo-lexicon.jsonl')
      expect(existsSync(path)).toBe(true)
    })

    test('lexicon contains expected tokens', () => {
      const path = join(process.cwd(), 'silo-lexicon.jsonl')
      const content = readFileSync(path, 'utf-8')
      expect(content).toContain('stuff → things')
      expect(content).toContain('enough is enough')
      expect(content).toContain('occupy the territory')
    })

    test('lexicon is valid JSONL', () => {
      const path = join(process.cwd(), 'silo-lexicon.jsonl')
      const content = readFileSync(path, 'utf-8')
      const lines = content.trim().split('\n')
      lines.forEach(line => {
        if (line.trim()) {
          const entry = JSON.parse(line)
          expect(entry).toHaveProperty('token')
          expect(entry).toHaveProperty('definition')
        }
      })
    })

    test('lexicon has 12 tokens', () => {
      const path = join(process.cwd(), 'silo-lexicon.jsonl')
      const content = readFileSync(path, 'utf-8')
      const lines = content.trim().split('\n').filter(l => l.trim())
      expect(lines.length).toBe(12)
    })

    test('all tokens have heuristics', () => {
      const path = join(process.cwd(), 'silo-lexicon.jsonl')
      const content = readFileSync(path, 'utf-8')
      const lines = content.trim().split('\n').filter(l => l.trim())
      lines.forEach(line => {
        const entry = JSON.parse(line)
        expect(entry).toHaveProperty('heuristic')
      })
    })
  })

  describe('JSONL validation', () => {
    test('each line is valid JSON', () => {
      const path = join(process.cwd(), 'silo-lexicon.jsonl')
      const content = readFileSync(path, 'utf-8')
      const lines = content.trim().split('\n').filter(l => l.trim())
      
      lines.forEach((line, idx) => {
        try {
          JSON.parse(line)
        } catch (e) {
          throw new Error(`Line ${idx + 1} is not valid JSON: ${line}`)
        }
      })
    })

    test('all entries have required fields', () => {
      const path = join(process.cwd(), 'silo-lexicon.jsonl')
      const content = readFileSync(path, 'utf-8')
      const lines = content.trim().split('\n').filter(l => l.trim())
      
      lines.forEach(line => {
        const entry = JSON.parse(line)
        expect(typeof entry.token).toBe('string')
        expect(entry.token.length).toBeGreaterThan(0)
        expect(typeof entry.definition).toBe('string')
        expect(entry.definition.length).toBeGreaterThan(0)
      })
    })
  })

  describe('temp directory integration', () => {
    let tempPath: string

    beforeAll(() => {
      tempPath = tempDir()
    })

    afterAll(() => {
      cleanupTempDir(tempPath)
    })

    test('can create new lexicon in temp directory', () => {
      const testLexicon = join(tempPath, 'silo-lexicon.jsonl')
      const content = `{"token": "test-token", "definition": "A test definition", "heuristic": "Test it"}`
      writeFileSync(testLexicon, content)

      const loaded = readFileSync(testLexicon, 'utf-8')
      const entries = loaded.trim().split('\n').map((l: string) => JSON.parse(l))
      
      expect(entries.length).toBe(1)
      expect(entries[0].token).toBe('test-token')
    })
  })
})
