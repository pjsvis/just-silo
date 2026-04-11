/**
 * Multi-Agent Coordination Tests
 * 
 * Tests the marker passing protocol for multi-agent workflows:
 * 1. Agent invokes another agent via marker
 * 2. Upstream agent writes to request/ directory
 * 3. Downstream agent reads from request/ and writes to done/
 */

import { describe, test, expect, beforeAll, afterAll, beforeEach } from 'bun:test'
import { existsSync, mkdirSync, writeFileSync, readFileSync, rmSync, cpSync } from 'node:fs'
import { join } from 'node:path'
import { execSync } from 'node:child_process'

// Paths
const PROJECT_ROOT = execSync('git rev-parse --show-toplevel', { encoding: 'utf-8' }).trim()
const TEST_DIR = join(PROJECT_ROOT, 'agents', '_template', 'tests')
const WORKSPACE = join(TEST_DIR, 'workspace')

// Helper to create a minimal test agent
function createTestAgent(name: string, markerDir: string) {
  const agentDir = join(WORKSPACE, markerDir)
  const markersDir = join(agentDir, 'markers')
  mkdirSync(join(markersDir, 'request'), { recursive: true })
  mkdirSync(join(markersDir, 'done'), { recursive: true })
  mkdirSync(join(markersDir, 'error'), { recursive: true })
  return { agentDir, markersDir }
}

// Helper to simulate marker passing
function writeRequest(agentDir: string, payload: object) {
  const requestFile = join(agentDir, 'markers', 'request', 'payload.jsonl')
  writeFileSync(requestFile, JSON.stringify(payload) + '\n')
  return requestFile
}

function pollRequest(agentDir: string): object | null {
  const requestFile = join(agentDir, 'markers', 'request', 'payload.jsonl')
  if (!existsSync(requestFile)) return null
  const content = readFileSync(requestFile, 'utf-8').trim()
  if (!content) return null
  return JSON.parse(content)
}

function writeDone(agentDir: string, payload: object) {
  const doneFile = join(agentDir, 'markers', 'done', 'result.jsonl')
  writeFileSync(doneFile, JSON.stringify(payload) + '\n')
  return doneFile
}

function readDone(agentDir: string): object[] {
  const doneFile = join(agentDir, 'markers', 'done', 'result.jsonl')
  if (!existsSync(doneFile)) return []
  const lines = readFileSync(doneFile, 'utf-8').trim().split('\n')
  return lines.filter(l => l.trim()).map(l => JSON.parse(l))
}

describe('Multi-Agent Marker Passing Protocol', () => {
  
  beforeAll(() => {
    // Create workspace
    mkdirSync(WORKSPACE, { recursive: true })
  })
  
  afterAll(() => {
    // Cleanup workspace
    rmSync(WORKSPACE, { recursive: true, force: true })
  })
  
  describe('1. Single Agent Workflow', () => {
    test('agent can receive request via marker', () => {
      const { agentDir } = createTestAgent('test-agent', 'single-agent')
      
      // Write a request
      const payload = { task: 'process', input: 'test-data' }
      writeRequest(agentDir, payload)
      
      // Poll for request
      const received = pollRequest(agentDir)
      
      expect(received).toEqual(payload)
    })
    
    test('agent can complete and write to done', () => {
      const { agentDir } = createTestAgent('test-agent', 'single-agent-2')
      
      // Simulate work
      const result = { status: 'success', output: 'processed' }
      writeDone(agentDir, result)
      
      // Read result
      const results = readDone(agentDir)
      
      expect(results).toHaveLength(1)
      expect(results[0]).toEqual(result)
    })
    
    test('agent clears request after processing', () => {
      const { agentDir } = createTestAgent('test-agent', 'clear-test')
      
      // Write request
      writeRequest(agentDir, { task: 'test' })
      
      // Process (simulated)
      rmSync(join(agentDir, 'markers', 'request', 'payload.jsonl'))
      
      // Verify cleared
      const received = pollRequest(agentDir)
      expect(received).toBeNull()
    })
  })
  
  describe('2. Two-Agent Pipeline', () => {
    test('upstream agent can invoke downstream agent', () => {
      // Create two agents: producer -> consumer
      const { agentDir: producerDir } = createTestAgent('producer', 'producer')
      const { agentDir: consumerDir } = createTestAgent('consumer', 'consumer')
      
      // Producer creates work
      const workResult = { data: 'processed-data', id: 123 }
      writeDone(producerDir, workResult)
      
      // Producer invokes consumer (simulated)
      const consumerRequest = {
        source: 'producer',
        workId: 123,
        input: readDone(producerDir)
      }
      writeRequest(consumerDir, consumerRequest)
      
      // Consumer polls
      const received = pollRequest(consumerDir)
      expect(received).toEqual(consumerRequest)
      expect(received!.input).toEqual([workResult])
    })
    
    test('downstream completes after upstream', () => {
      const { agentDir: producerDir } = createTestAgent('producer', 'producer-2')
      const { agentDir: consumerDir } = createTestAgent('consumer', 'consumer-2')
      
      // Producer does work
      writeDone(producerDir, { stage: 'produce', result: 'item-1' })
      
      // Consumer receives work
      const work = readDone(producerDir)
      writeRequest(consumerDir, { items: work })
      
      // Consumer processes
      const processed = work.map((item: any) => ({
        ...item,
        stage: 'consume',
        processed: true
      }))
      writeDone(consumerDir, ...processed)
      
      // Verify final output
      const finalResults = readDone(consumerDir)
      expect(finalResults).toHaveLength(1)
      expect(finalResults[0].stage).toBe('consume')
      expect(finalResults[0].processed).toBe(true)
    })
    
    test('pipeline maintains data flow', () => {
      const { agentDir: stage1 } = createTestAgent('stage1', 's1')
      const { agentDir: stage2 } = createTestAgent('stage2', 's2')
      const { agentDir: stage3 } = createTestAgent('stage3', 's3')
      
      // Stage 1
      writeDone(stage1, { pipeline: 1, value: 'raw' })
      
      // Stage 2 receives from stage 1
      writeRequest(stage2, { input: readDone(stage1) })
      writeDone(stage2, { pipeline: 2, value: 'validated' })
      
      // Stage 3 receives from stage 2
      writeRequest(stage3, { input: readDone(stage2) })
      writeDone(stage3, { pipeline: 3, value: 'enriched' })
      
      // Final result
      const final = readDone(stage3)
      expect(final[0].value).toBe('enriched')
      expect(final[0].pipeline).toBe(3)
    })
  })
  
  describe('3. Error Handling', () => {
    test('agent handles missing request gracefully', () => {
      const { agentDir } = createTestAgent('test-agent', 'no-request')
      
      const received = pollRequest(agentDir)
      expect(received).toBeNull()
    })
    
    test('agent can mark error state', () => {
      const { agentDir } = createTestAgent('test-agent', 'error-test')
      
      // Write error marker
      const errorFile = join(agentDir, 'markers', 'error', 'last.jsonl')
      writeFileSync(errorFile, JSON.stringify({
        error: 'Validation failed',
        timestamp: new Date().toISOString()
      }) + '\n')
      
      expect(existsSync(errorFile)).toBe(true)
    })
    
    test('downstream handles upstream error', () => {
      const { agentDir: producerDir } = createTestAgent('producer', 'error-producer')
      const { agentDir: consumerDir } = createTestAgent('consumer', 'error-consumer')
      
      // Producer fails
      const errorFile = join(producerDir, 'markers', 'error', 'last.jsonl')
      writeFileSync(errorFile, JSON.stringify({ error: 'Upstream failed' }) + '\n')
      
      // Consumer checks for error before proceeding
      const hasError = existsSync(errorFile)
      
      if (hasError) {
        writeRequest(consumerDir, { status: 'blocked', reason: 'upstream-error' })
      }
      
      const received = pollRequest(consumerDir)
      expect(received.status).toBe('blocked')
    })
  })
  
  describe('4. Coordination Patterns', () => {
    test('fan-out: one producer to multiple consumers', () => {
      const { agentDir: producer } = createTestAgent('producer', 'fan-out-producer')
      const { agentDir: consumer1 } = createTestAgent('consumer1', 'fan-out-c1')
      const { agentDir: consumer2 } = createTestAgent('consumer2', 'fan-out-c2')
      
      // Producer creates work
      const workData = { items: ['a', 'b', 'c'] }
      writeDone(producer, workData)
      
      // Fan out to consumers
      writeRequest(consumer1, { portion: workData.items.slice(0, 2), consumer: 1 })
      writeRequest(consumer2, { portion: workData.items.slice(2), consumer: 2 })
      
      expect(pollRequest(consumer1).portion).toEqual(['a', 'b'])
      expect(pollRequest(consumer2).portion).toEqual(['c'])
    })
    
    test('fan-in: multiple producers to one consumer', () => {
      const { agentDir: producer1 } = createTestAgent('producer1', 'fan-in-p1')
      const { agentDir: producer2 } = createTestAgent('producer2', 'fan-in-p2')
      const { agentDir: consumer } = createTestAgent('consumer', 'fan-in-consumer')
      
      // Producers do work
      writeDone(producer1, { from: 1, value: 'data-1' })
      writeDone(producer2, { from: 2, value: 'data-2' })
      
      // Consumer aggregates
      const combined = [...readDone(producer1), ...readDone(producer2)]
      writeRequest(consumer, { aggregated: combined })
      
      const received = pollRequest(consumer)
      expect(received.aggregated).toHaveLength(2)
    })
  })
})

describe('Agent Invocation Scripts', () => {
  
  test('agent-invoke.sh can pass requests', () => {
    const invokeScript = join(PROJECT_ROOT, 'scripts', 'agent-invoke.sh')
    expect(existsSync(invokeScript)).toBe(true)
    
    // Check it's executable
    const stat = require('fs').statSync(invokeScript)
    expect(stat.mode & 0o111).not.toBe(0)
  })
  
  test('code-review-agent coordinate.sh works', () => {
    const coordScript = join(PROJECT_ROOT, 'agents', 'code-review-agent', 'scripts', 'coordinate.sh')
    expect(existsSync(coordScript)).toBe(true)
    
    // Test coordinate poll
    const output = execSync(`${coordScript} status`, { encoding: 'utf-8' })
    expect(output.trim()).toMatch(/IDLE|RUNNING|ERROR|DONE/)
  })
})
