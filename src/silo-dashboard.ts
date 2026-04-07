#!/usr/bin/env bun
/**
 * silo-dashboard - Status dashboard generator with sparklines
 * 
 * "Wall of Light" - Industrial SCADA-style status page
 * Reads status.json from silos and generates HTML dashboard
 */

import { readdirSync, existsSync, readFileSync, writeFileSync } from 'node:fs'
import { join, basename } from 'node:path'
import { generateSvgSparkline, parseDataJsonl, calculateEfficiency } from './sparkline'

// Config
const SILO_DIR = process.env.SILO_DASH_DIR || process.cwd()
const OUTPUT_FILE = process.env.SILO_DASH_OUTPUT || 'dashboard.html'
const REFRESH_SEC = parseInt(process.env.SILO_DASH_REFRESH || '30')

interface SiloStatus {
  name: string
  path: string
  state: 'green' | 'amber' | 'red' | 'unknown'
  message: string
  lastUpdate: string
  active: number
  quarantine: number
  output: number
  sparkline: string
  efficiency: number
}

// ============================================
// DISCOVERY: Find silos (directories with .silo file)
// ============================================
function discoverSilos(): string[] {
  const silos: string[] = []
  
  if (!existsSync(SILO_DIR)) return silos
  
  try {
    const entries = readdirSync(SILO_DIR, { withFileTypes: true })
    for (const entry of entries) {
      if (!entry.isDirectory()) continue
      // A silo is any directory with a .silo manifest
      const siloPath = join(SILO_DIR, entry.name, '.silo')
      if (existsSync(siloPath)) {
        silos.push(entry.name)
      }
    }
  } catch {
    // Ignore errors
  }
  
  return silos
}

// ============================================
// READ: Get status for a silo
// ============================================
function getSiloStatus(name: string): SiloStatus {
  const path = join(SILO_DIR, name)
  const statusPath = join(path, 'status.json')
  const dataPath = join(path, 'data.jsonl')
  
  let state: 'green' | 'amber' | 'red' | 'unknown' = 'unknown'
  let message = 'No status file'
  let lastUpdate = 'Never'
  let active = 0
  let quarantine = 0
  let output = 0
  let sparkline = ''
  let efficiency = 0
  
  // Try to read status.json
  if (existsSync(statusPath)) {
    try {
      const content = readFileSync(statusPath, 'utf-8')
      const status = JSON.parse(content)
      state = status.state || 'unknown'
      message = status.message || 'OK'
      lastUpdate = status.lastUpdate || 'Unknown'
    } catch {
      message = 'Invalid status.json'
    }
  }
  
  // Try to count data files and generate sparkline
  try {
    if (existsSync(dataPath)) {
      const content = readFileSync(dataPath, 'utf-8')
      active = content.trim().split('\n').filter(l => l.trim()).length
      
      // Generate sparkline from data
      const points = parseDataJsonl(content)
      const values = points.map(p => p.value)
      efficiency = calculateEfficiency(values)
      
      // Color based on efficiency
      const sparkColor = efficiency >= 75 ? '#22c55e' : 
                        efficiency >= 50 ? '#eab308' : '#ef4444'
      
      sparkline = generateSvgSparkline(values, 80, 24, sparkColor)
    }
    const quarantinePath = join(path, 'quarantine.jsonl')
    if (existsSync(quarantinePath)) {
      const content = readFileSync(quarantinePath, 'utf-8')
      quarantine = content.trim().split('\n').filter(l => l.trim()).length
    }
    const outputPath = join(path, 'final_output.jsonl')
    if (existsSync(outputPath)) {
      const content = readFileSync(outputPath, 'utf-8')
      output = content.trim().split('\n').filter(l => l.trim()).length
    }
  } catch {
    // Ignore
  }
  
  return {
    name,
    path,
    state,
    message,
    lastUpdate,
    active,
    quarantine,
    output,
    sparkline,
    efficiency
  }
}

// ============================================
// GENERATE: HTML dashboard
// ============================================
function generateDashboard(silos: SiloStatus[]): string {
  const rows = silos.map(silo => {
    const color = silo.state === 'green' ? '#22c55e' : 
                  silo.state === 'amber' ? '#eab308' : 
                  silo.state === 'red' ? '#ef4444' : '#6b7280'
    const bg = silo.state === 'green' ? 'rgba(34,197,94,0.1)' : 
               silo.state === 'amber' ? 'rgba(234,179,8,0.1)' : 
               silo.state === 'red' ? 'rgba(239,68,68,0.1)' : 'rgba(107,114,128,0.1)'
    
    const sparklineSvg = silo.sparkline || 
      `<svg width="80" height="24" viewBox="0 0 80 24"><line x1="0" y1="12" x2="80" y2="12" stroke="#6b7280" stroke-width="1" stroke-dasharray="4"/></svg>`
    
    return `
    <tr style="background: ${bg}">
      <td>
        <span style="display: inline-block; width: 12px; height: 12px; border-radius: 50%; background: ${color}"></span>
        <strong>${silo.name}</strong>
      </td>
      <td>${silo.message}</td>
      <td>
        <svg width="80" height="24" viewBox="0 0 80 24" style="display: block;">
          ${sparklineSvg}
        </svg>
      </td>
      <td>${silo.efficiency}%</td>
      <td>${silo.active}</td>
      <td>${silo.quarantine}</td>
      <td>${silo.output}</td>
      <td>${silo.lastUpdate}</td>
    </tr>`
  }).join('\n')
  
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="refresh" content="${REFRESH_SEC}">
  <title>Silo Dashboard</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #0f172a;
      color: #e2e8f0;
      min-height: 100vh;
      padding: 2rem;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 2rem;
    }
    h1 { font-size: 1.5rem; font-weight: 600; }
    .meta { color: #64748b; font-size: 0.875rem; }
    .legend {
      display: flex;
      gap: 1.5rem;
      margin-bottom: 1rem;
      flex-wrap: wrap;
    }
    .legend-item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
    }
    .dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
    }
    .dot.green { background: #22c55e; }
    .dot.amber { background: #eab308; }
    .dot.red { background: #ef4444; }
    .dot.gray { background: #6b7280; }
    table {
      width: 100%;
      border-collapse: collapse;
      background: #1e293b;
      border-radius: 8px;
      overflow: hidden;
    }
    th {
      background: #334155;
      padding: 0.75rem 1rem;
      text-align: left;
      font-weight: 600;
      font-size: 0.875rem;
      color: #94a3b8;
    }
    td {
      padding: 0.75rem 1rem;
      border-top: 1px solid #334155;
    }
    tr:hover { background: rgba(255,255,255,0.02); }
    .empty {
      text-align: center;
      padding: 3rem;
      color: #64748b;
    }
    .sparkline-cell {
      padding: 0.25rem 0 !important;
    }
    .efficiency {
      font-weight: 600;
      color: #94a3b8;
    }
    .efficiency.high { color: #22c55e; }
    .efficiency.medium { color: #eab308; }
    .efficiency.low { color: #ef4444; }
    @media (max-width: 900px) {
      .header { flex-direction: column; gap: 1rem; }
      table { font-size: 0.875rem; }
      th:nth-child(n+5), td:nth-child(n+5) { display: none; }
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>Silo Dashboard</h1>
    <div class="meta">
      Mesh: ${basename(SILO_DIR)} | 
      Silos: ${silos.length} | 
      Refresh: ${REFRESH_SEC}s
    </div>
  </div>
  
  <div class="legend">
    <div class="legend-item"><span class="dot green"></span> Healthy</div>
    <div class="legend-item"><span class="dot amber"></span> Processing</div>
    <div class="legend-item"><span class="dot red"></span> Alert</div>
    <div class="legend-item"><span class="dot gray"></span> Unknown</div>
    <div class="legend-item" style="margin-left: 2rem;">
      <span style="color: #94a3b8;">Sparklines show trend over time</span>
    </div>
  </div>
  
  ${silos.length > 0 ? `
  <table>
    <thead>
      <tr>
        <th>Silo</th>
        <th>Status</th>
        <th>Trend</th>
        <th>Eff.</th>
        <th>Active</th>
        <th>Quarantine</th>
        <th>Output</th>
        <th>Last Update</th>
      </tr>
    </thead>
    <tbody>
      ${rows}
    </tbody>
  </table>` : `
  <div class="empty">
    <p>No silos with status files found.</p>
    <p style="margin-top: 0.5rem; font-size: 0.875rem;">
      Run 'just status' in a silo to create status.json
    </p>
  </div>`}
</body>
</html>`
}

// ============================================
// MAIN
// ============================================
function main() {
  console.log(`[silo-dashboard] Scanning ${SILO_DIR}...`)
  
  const siloNames = discoverSilos()
  console.log(`[silo-dashboard] Found ${siloNames.length} silos`)
  
  const statuses = siloNames.map(name => getSiloStatus(name))
  
  const html = generateDashboard(statuses)
  const outputPath = join(SILO_DIR, OUTPUT_FILE)
  writeFileSync(outputPath, html)
  
  console.log(`[silo-dashboard] Generated ${outputPath}`)
  console.log(`[silo-dashboard] Open in browser to view`)
}

// Run if called directly
if (import.meta.main) {
  main()
}

export { generateDashboard, getSiloStatus }
