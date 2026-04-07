/**
 * sparkline - ASCII/SVG sparkline generator
 * 
 * Generates trend indicators from event data.
 * Uses Unicode block elements for CLI, SVG polyline for web.
 */

// Config
const BLOCK_CHARS = ' ▁▂▃▄▅▆▇█'
const WIDTH = 12  // Default sparkline width

export interface DataPoint {
  timestamp: number
  value: number  // 0-100
  type?: 'success' | 'retry' | 'failure'
}

export interface SparklineOptions {
  width?: number
  height?: number
  color?: string
  showLabel?: boolean
}

/**
 * Generate sparkline from array of values (0-100)
 */
export function generateSparkline(values: number[], width: number = WIDTH): string {
  if (values.length === 0) return BLOCK_CHARS[0].repeat(width)
  
  // Normalize to width
  const samples = sampleArray(values, width)
  
  // Map to block characters
  return samples.map(v => {
    const idx = Math.round(Math.min(100, Math.max(0, v)) / 100 * (BLOCK_CHARS.length - 1))
    return BLOCK_CHARS[idx]
  }).join('')
}

/**
 * Generate SVG polyline for web
 */
export function generateSvgSparkline(
  values: number[],
  width: number = 80,
  height: number = 20,
  color: string = '#22c55e'
): string {
  if (values.length < 2) {
    return `<polyline points="0,${height} ${width},${height}" fill="none" stroke="${color}" stroke-width="2"/>`
  }
  
  const samples = sampleArray(values, width)
  const min = Math.min(...samples)
  const max = Math.max(...samples)
  const range = max - min || 1
  
  const points = samples.map((v, i) => {
    const x = (i / (width - 1)) * width
    const y = height - ((v - min) / range) * height
    return `${x},${y}`
  }).join(' ')
  
  return `<polyline points="${points}" fill="none" stroke="${color}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>`
}

/**
 * Calculate efficiency percentage from sparkline
 */
export function calculateEfficiency(values: number[]): number {
  if (values.length === 0) return 0
  const avg = values.reduce((a, b) => a + b, 0) / values.length
  return Math.round(avg)
}

/**
 * Sample array to target length
 */
function sampleArray(arr: number[], target: number): number[] {
  if (arr.length <= target) return arr
  
  const result: number[] = []
  const step = arr.length / target
  
  for (let i = 0; i < target; i++) {
    const idx = Math.floor(i * step)
    result.push(arr[idx])
  }
  
  return result
}

/**
 * Parse heartbeat.jsonl to get status values
 * Format: {"ts": 1234567890, "status": "success|retry|failure"}
 */
export function parseHeartbeat(content: string): DataPoint[] {
  return content
    .trim()
    .split('\n')
    .filter(line => line.trim())
    .map(line => {
      try {
        const entry = JSON.parse(line)
        let value = 50  // Default to amber
        let type: 'success' | 'retry' | 'failure' = 'success'
        
        if (entry.status === 'success') {
          value = 100
          type = 'success'
        } else if (entry.status === 'retry' || entry.status === 'pending') {
          value = 50
          type = 'retry'
        } else if (entry.status === 'failure' || entry.status === 'error') {
          value = 0
          type = 'failure'
        }
        
        return {
          timestamp: entry.ts || Date.now(),
          value,
          type
        }
      } catch {
        return null
      }
    })
    .filter((p): p is DataPoint => p !== null)
}

/**
 * Generate trend from data.jsonl entries (simpler format)
 * Format: one JSON object per line
 */
export function parseDataJsonl(content: string): DataPoint[] {
  return content
    .trim()
    .split('\n')
    .filter(line => line.trim())
    .map((line, idx) => {
      try {
        const entry = JSON.parse(line)
        // Assume sequential entries with time-based spacing
        const now = Date.now()
        const offset = (content.split('\n').length - idx) * 60000  // 1 min apart backwards
        
        return {
          timestamp: now - offset,
          value: 75,  // Default success rate
          type: 'success' as const
        }
      } catch {
        return null
      }
    })
    .filter((p): p is DataPoint => p !== null)
    .reverse()  // Oldest first
}

/**
 * CLI formatter for a single silo
 */
export function formatSiloTrend(
  name: string,
  values: number[],
  state: string
): string {
  const sparkline = generateSparkline(values)
  const efficiency = calculateEfficiency(values)
  
  const stateIcon = state === 'green' ? '🟢' : 
                    state === 'amber' ? '🟡' : 
                    state === 'red' ? '🔴' : '⚪'
  
  return `${stateIcon} ${name.padEnd(20)} ${sparkline} [${efficiency}%]`
}

/**
 * Full CLI output
 */
export function formatCliOutput(silos: { name: string; values: number[]; state: string }[]): string {
  const lines = [
    '=== Silo Trends ===',
    '',
    ...silos.map(s => formatSiloTrend(s.name, s.values, s.state)),
    '',
    'Legend: █=100% ▇=87% ▆=75% ▅=62% ▄=50% ▃=37% ▂=25% ▁=12%  =0%',
    `Time: ${new Date().toISOString()}`
  ]
  
  return lines.join('\n')
}
