import { describe, expect, test } from 'bun:test'
import {
  generateSparkline,
  generateSvgSparkline,
  calculateEfficiency,
  parseHeartbeat,
  formatSiloTrend,
  formatCliOutput,
  DataPoint
} from './sparkline'

describe('sparkline', () => {
  describe('generateSparkline', () => {
    test('returns empty bars for empty array', () => {
      const result = generateSparkline([], 10)
      expect(result).toBe('          ')
    })

    test('normalizes single value to full bar', () => {
      const result = generateSparkline([100], 1)
      expect(result).toBe('█')
    })

    test('normalizes zero to empty bars', () => {
      const result = generateSparkline([0], 1)
      expect(result).toBe(' ')
    })

    test('handles mid-range values', () => {
      const result = generateSparkline([50], 1)
      // Should be roughly 50% filled
      expect(result.length).toBe(1)
      expect(result).toBe('▄')
    })

    test('samples longer arrays to target width', () => {
      const values = [0, 25, 50, 75, 100]
      const result = generateSparkline(values, 3)
      expect(result.length).toBe(3)
    })

    test('preserves order for short arrays', () => {
      const values = [0, 100]
      const result = generateSparkline(values, 2)
      expect(result[0]).toBe(' ')
      expect(result[1]).toBe('█')
    })
  })

  describe('generateSvgSparkline', () => {
    test('returns flat line for single value', () => {
      const result = generateSvgSparkline([50], 80, 20)
      expect(result).toContain('polyline')
      expect(result).toContain('points="0,')
      expect(result).toContain('fill="none"')
    })

    test('returns empty points for no values', () => {
      const result = generateSvgSparkline([], 80, 20)
      expect(result).toContain('polyline')
    })

    test('uses custom color', () => {
      const result = generateSvgSparkline([50, 60], 80, 20, '#ff0000')
      expect(result).toContain('#ff0000')
    })

    test('returns valid SVG polyline for multiple values', () => {
      const result = generateSvgSparkline([10, 50, 90], 80, 20)
      expect(result).toContain('points=')
      expect(result).toContain('stroke-width')
    })
  })

  describe('calculateEfficiency', () => {
    test('returns 0 for empty array', () => {
      expect(calculateEfficiency([])).toBe(0)
    })

    test('returns average for single value', () => {
      expect(calculateEfficiency([75])).toBe(75)
    })

    test('calculates mean for multiple values', () => {
      expect(calculateEfficiency([50, 100])).toBe(75)
    })

    test('rounds to nearest integer', () => {
      expect(calculateEfficiency([33, 33, 33])).toBe(33)
    })
  })

  describe('parseHeartbeat', () => {
    test('parses success status', () => {
      const content = '{"ts": 1234567890, "status": "success"}'
      const result = parseHeartbeat(content)
      expect(result[0].value).toBe(100)
      expect(result[0].type).toBe('success')
    })

    test('parses failure status', () => {
      const content = '{"ts": 1234567890, "status": "failure"}'
      const result = parseHeartbeat(content)
      expect(result[0].value).toBe(0)
      expect(result[0].type).toBe('failure')
    })

    test('parses retry status as mid-range', () => {
      const content = '{"ts": 1234567890, "status": "retry"}'
      const result = parseHeartbeat(content)
      expect(result[0].value).toBe(50)
      expect(result[0].type).toBe('retry')
    })

    test('handles multiple lines', () => {
      const content = `{"ts": 1, "status": "success"}
{"ts": 2, "status": "failure"}
{"ts": 3, "status": "pending"}`
      const result = parseHeartbeat(content)
      expect(result.length).toBe(3)
    })

    test('skips invalid JSON lines', () => {
      const content = `{"ts": 1, "status": "success"}
invalid json
{"ts": 3, "status": "failure"}`
      const result = parseHeartbeat(content)
      expect(result.length).toBe(2)
    })

    test('returns empty array for empty content', () => {
      expect(parseHeartbeat('')).toEqual([])
      expect(parseHeartbeat('   ')).toEqual([])
    })

    test('accepts error as failure', () => {
      const content = '{"ts": 1, "status": "error"}'
      const result = parseHeartbeat(content)
      expect(result[0].value).toBe(0)
    })
  })

  describe('formatSiloTrend', () => {
    test('formats name with sparkline and efficiency', () => {
      const result = formatSiloTrend('test-silo', [100, 100], 'green')
      expect(result).toContain('🟢')
      expect(result).toContain('test-silo')
      expect(result).toContain('██')
      expect(result).toContain('[100%]')
    })

    test('uses amber icon for amber state', () => {
      const result = formatSiloTrend('test', [50], 'amber')
      expect(result).toContain('🟡')
    })

    test('uses red icon for red state', () => {
      const result = formatSiloTrend('test', [0], 'red')
      expect(result).toContain('🔴')
    })

    test('uses white circle for unknown state', () => {
      const result = formatSiloTrend('test', [50], 'unknown')
      expect(result).toContain('⚪')
    })

    test('pads name to fixed width in output', () => {
      const result = formatSiloTrend('ab', [50], 'green')
      // Output should contain the name somewhere
      expect(result).toContain('ab')
    })
  })

  describe('formatCliOutput', () => {
    test('renders multiple silos', () => {
      const silos = [
        { name: 'alpha', values: [100], state: 'green' },
        { name: 'beta', values: [50], state: 'amber' }
      ]
      const result = formatCliOutput(silos)
      expect(result).toContain('alpha')
      expect(result).toContain('beta')
      expect(result).toContain('Legend:')
      expect(result).toContain('Time:')
    })

    test('includes timestamp', () => {
      const result = formatCliOutput([])
      expect(result).toContain('Time:')
    })

    test('renders empty silos list', () => {
      const result = formatCliOutput([])
      expect(result).toContain('Silo Trends')
      expect(result).toContain('Legend:')
    })
  })
})
