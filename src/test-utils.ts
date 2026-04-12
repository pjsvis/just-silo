import { mkdirSync, rmSync } from 'node:fs'
import { join } from 'node:path'
import { randomUUID } from 'node:crypto'

/**
 * Create a temporary directory for tests
 */
export function tempDir(): string {
  const tmpDir = '/tmp'
  const name = `silo-test-${randomUUID()}`
  const path = join(tmpDir, name)
  mkdirSync(path, { recursive: true })
  return path
}

/**
 * Clean up a temporary directory
 */
export function cleanupTempDir(path: string): void {
  try {
    rmSync(path, { recursive: true, force: true })
  } catch {
    // Ignore cleanup errors
  }
}
