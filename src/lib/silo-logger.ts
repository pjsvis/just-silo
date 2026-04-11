/**
 * silo-logger - Standard JSONL logging for Silo
 * 
 * Provides a structured logging interface that outputs Pino-compatible
 * JSONL logs for enterprise observability integration.
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'fatal'

export interface LogEntry {
  level: number
  time: number
  msg: string
  pid: number
  hostname: string
  silo: string
  ts: string
  action?: string
  status?: 'success' | 'partial' | 'failure' | 'skipped'
  duration_ms?: number
  entropy?: number
  session?: string
  error?: string
  [key: string]: unknown
}

// Pino-compatible log levels
const LEVELS: Record<LogLevel, number> = {
  debug: 20,
  info: 30,
  warn: 40,
  error: 50,
  fatal: 60
}

export class SiloLogger {
  private logDir: string
  private siloName: string
  private pid: number

  constructor(logDir = '.silo/logs', siloName = 'silo') {
    this.logDir = logDir
    this.siloName = siloName
    this.pid = process.pid
  }

  private formatEntry(level: LogLevel, msg: string, extra: Record<string, unknown> = {}): LogEntry {
    return {
      level: LEVELS[level],
      time: Date.now(),
      msg,
      pid: this.pid,
      hostname: process.env.HOSTNAME || require('os').hostname(),
      silo: this.siloName,
      ts: new Date().toISOString(),
      ...extra
    }
  }

  private write(entry: LogEntry): void {
    // Ensure directory exists
    const { promises: fs } = require('fs')
    fs.mkdir(this.logDir, { recursive: true }).catch(() => {})

    // Append to telemetry.jsonl
    const logFile = `${this.logDir}/telemetry.jsonl`
    fs.appendFile(logFile, JSON.stringify(entry) + '\n').catch(() => {
      // Fallback to stderr if file write fails
      console.error('[silo-logger] Failed to write to log file:', entry)
    })

    // Also log to stderr for local debugging
    if (process.env.SILO_LOG_DEBUG === '1') {
      const level = Object.entries(LEVELS).find(([, v]) => v === entry.level)?.[0] || 'info'
      console.error(`[${level}] ${entry.msg}`)
    }
  }

  debug(msg: string, extra: Record<string, unknown> = {}): void {
    this.write(this.formatEntry('debug', msg, extra))
  }

  info(msg: string, extra: Record<string, unknown> = {}): void {
    this.write(this.formatEntry('info', msg, extra))
  }

  warn(msg: string, extra: Record<string, unknown> = {}): void {
    this.write(this.formatEntry('warn', msg, extra))
  }

  error(msg: string, extra: Record<string, unknown> = {}): void {
    this.write(this.formatEntry('error', msg, extra))
  }

  fatal(msg: string, extra: Record<string, unknown> = {}): void {
    this.write(this.formatEntry('fatal', msg, extra))
  }

  // Convenience method for workflow actions
  action(action: string, status: LogEntry['status'], durationMs: number, msg?: string): void {
    this.info(msg || `${action} ${status}`, {
      action,
      status,
      duration_ms: durationMs
    })
  }

  // Log entropy measurement
  entropy(action: string, value: number, extra: Record<string, unknown> = {}): void {
    this.info(`Entropy for ${action}: ${(value * 100).toFixed(1)}%`, {
      action,
      entropy: value,
      ...extra
    })
  }
}

// Singleton instance
let _logger: SiloLogger | null = null

export function getLogger(logDir?: string, siloName?: string): SiloLogger {
  if (!_logger) {
    _logger = new SiloLogger(logDir, siloName)
  }
  return _logger
}
