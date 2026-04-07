import { describe, expect, test } from 'bun:test'
import { readFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'

describe('silo-api-server', () => {
  describe('source code verification', () => {
    test('server source file exists', () => {
      const path = join(process.cwd(), 'src/silo-api-server.ts')
      expect(existsSync(path)).toBe(true)
    })

    test('uses Hono framework', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), 'utf-8')
      expect(source).toContain("import { Hono }")
      expect(source).toContain("new Hono()")
    })

    test('imports streamSSE from hono/streaming', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), 'utf-8')
      expect(source).toContain("from 'hono/streaming'")
    })
  })

  describe('SSE streaming endpoints', () => {
    test('defines /stream/status endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/stream/status'")
      expect(source).toContain("streamSSE")
    })

    test('defines /stream/heartbeat endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/stream/heartbeat'")
    })

    test('defines /stream/logs endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/stream/logs'")
    })

    test('defines /stream/all endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/stream/all'")
    })

    test('defines /rpc/:verb execution endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.post('/rpc/:verb'")
    })

    test('defines /exec/:verb execution endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.post('/exec/:verb'")
    })
  })

  describe('discovery endpoints', () => {
    test('defines /health endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/health'")
    })

    test('defines /manifest endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/manifest'")
    })

    test('defines /capabilities endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/capabilities'")
    })

    test('defines /verbs endpoint', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("app.get('/verbs'")
    })
  })

  describe('telemetry support', () => {
    test('handles status.json', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('status.json')
    })

    test('handles heartbeat.jsonl', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('heartbeat.jsonl')
    })

    test('handles data.jsonl', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('data.jsonl')
    })
  })

  describe('configuration', () => {
    test('uses environment variables for config', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('process.env')
    })

    test('has PORT configuration', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('PORT')
    })

    test('has SILO_DIR configuration', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('SILO_DIR')
    })

    test('has STREAM_INTERVAL configuration', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('STREAM_INTERVAL')
    })
  })

  describe('execution features', () => {
    test('uses child_process spawn for just commands', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("spawn('just'")
    })

    test('captures stdout and stderr', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain("stdout.on")
      expect(source).toContain("stderr.on")
    })
  })

  describe('JSDoc comments', () => {
    test('has JSDoc for SSE endpoints', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('SSE endpoint')
    })

    test('documents stream types', () => {
      const source = readFileSync(join(process.cwd(), 'src/silo-api-server.ts'), "utf-8")
      expect(source).toContain('Real-time')
    })
  })
})
