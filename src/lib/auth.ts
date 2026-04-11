/**
 * Auth utilities for external API
 * 
 * Security model: External API requires auth by default.
 * Set SILO_AUTH_DISABLED=true only for local development.
 */

export interface AuthConfig {
  enabled: boolean
  token?: string
  headerName: string
}

const DEFAULT_HEADER = 'X-Silo-Token'

export function getAuthConfig(): AuthConfig {
  const token = process.env.SILO_API_TOKEN
  const explicitDisable = process.env.SILO_AUTH_DISABLED === 'true'
  const headerName = process.env.SILO_AUTH_HEADER || DEFAULT_HEADER
  
  // Auth is required unless explicitly disabled (for local dev only)
  const enabled = explicitDisable ? false : (token ? true : false)
  
  if (!enabled && !explicitDisable && !token) {
    // Token not set - auth will be required, middleware will deny all requests
    console.warn('[AUTH] WARNING: SILO_API_TOKEN not set. External API will deny all requests.')
  } else if (explicitDisable) {
    console.warn('[AUTH] WARNING: Authentication DISABLED via SILO_AUTH_DISABLED. Do not use in production!')
  }
  
  return { enabled, token, headerName }
}

export function createAuthMiddleware(config: AuthConfig) {
  return async (c: any, next: () => Promise<void>) => {
    // Skip auth if disabled
    if (!config.enabled) {
      await next()
      return
    }
    
    // Skip health check (allow liveness probes without auth)
    if (c.req.path === '/health') {
      await next()
      return
    }
    
    const providedToken = c.req.header(config.headerName)
    
    if (!providedToken) {
      c.status(401)
      return c.json({ error: 'Missing authentication token' }, 401)
    }
    
    if (providedToken !== config.token) {
      c.status(403)
      return c.json({ error: 'Invalid authentication token' }, 403)
    }
    
    await next()
  }
}

export function logApiCall(config: AuthConfig, path: string, ip: string) {
  const logLine = JSON.stringify({
    timestamp: new Date().toISOString(),
    path,
    ip,
    auth: config.enabled ? 'required' : 'disabled'
  })
  console.log(`[API] ${logLine}`)
}
