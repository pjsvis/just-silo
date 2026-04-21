---
date: 2026-04-10
tags:
  - playbook
  - bun
  - runtime
  - typescript
agent: antigravity
environment: local
---

# Bun Playbook

## Purpose
Standards and patterns for using Bun as the primary runtime, replacing Node.js and its ecosystem.

## Context & Prerequisites
- Bun v1.3.12+ installed (`brew install oven-sh/bun/bun`)
- Project uses `bun` as runtime, test runner, bundler, and package manager
- `just` available for task runner delegation

## Core Usage

Default to Bun over Node.js equivalents:

| Use | Instead of |
|-----|-----------|
| `bun <file>` | `node <file>`, `ts-node <file>` |
| `bun test` | `jest`, `vitest` |
| `bun build` | `webpack`, `esbuild` |
| `bun install` | `npm install`, `yarn`, `pnpm` |
| `bun run <script>` | `npm run <script>` |
| `bun ./file.md` | nothing — this is new (but see note below) |

Bun auto-loads `.env` files. Don't use `dotenv`.

## APIs — Built-in Replacements

| Bun API | Replaces |
|---------|---------|
| `Bun.serve()` | `express`, `fastify`, `hono` |
| `bun:sqlite` | `better-sqlite3` |
| `Bun.redis` | `ioredis` |
| `Bun.sql` | `pg`, `postgres.js` |
| `WebSocket` | `ws` |
| `Bun.file()` | `node:fs` readFile/writeFile |
| `Bun.$` | `execa`, `child_process` |
| `Bun.Glob` | `glob`, `fast-glob` |

## Testing

```ts
import { test, expect } from "bun:test";

test("hello world", () => {
  expect(1).toBe(1);
});
```

Run with `bun test`. Watch mode: `bun test --watch`.

## v1.3.12 Features

### Bun.cron() — In-Process Scheduler

Schedule recurring tasks inside a long-running process. Shares state with your app.

```ts
// In-process cron — runs inside the Bun process
Bun.cron("* * * * *", async () => {
  console.log("Every minute");
});

// Disposable — auto-stops at scope exit
using job = Bun.cron("0 9 * * *", async () => {
  await dailyCleanup();
});
```

**Key behaviours:**
- **No overlap** — next fire waits for handler to settle
- **UTC** — `0 9 * * *` means 09:00 UTC (unlike OS-level `Bun.cron(path, schedule, title)` which uses local time)
- **`--hot` safe** — jobs cleared before module re-evaluation
- **Error handling** — matches `setTimeout` semantics (`unhandledRejection` etc.)

### bun ./file.md — Terminal Markdown Rendering

```bash
bun ./README.md        # renders markdown as ANSI output
bun ./briefs-queue.md  # pretty print any markdown file
```

Also available programmatically:

```ts
const out = Bun.markdown.ansi("# Hello\n\n**bold** and *italic*\n");
process.stdout.write(out);
```

**Opinion: not as good as Glow.** Bun's renderer handles basic markdown well but lacks Glow's typography, theme support, and polish. Use `glow` for reading docs, use `bun ./file.md` for quick previews where Glow isn't installed.

### Bun.WebView — Headless Browser Automation

Native headless browser with two backends: WebKit (macOS, zero deps) and Chrome (cross-platform).

```ts
await using view = new Bun.WebView({ width: 800, height: 600 });
await view.navigate("https://example.com");
await view.click("a[href='/docs']");
await view.scrollTo("#content");
const title = await view.evaluate("document.title");
const png = await view.screenshot({ format: "png" });
await Bun.write("screenshot.png", png);
```

All clicks are `isTrusted: true` — sites can't distinguish from real input.

### using / await using — Explicit Resource Management

TC39 Explicit Resource Management now supported natively:

```ts
function readFile(path: string) {
  using file = openFile(path); // auto-dispose at block end
  return file.read();
}

async function query(url: string) {
  await using conn = await connect(url); // auto-await dispose
  return conn.getData();
}
```

Use `using` for file handles, WebSocket connections, cron jobs, WebView instances.

### Async Stack Traces

Native APIs (`node:fs`, `Bun.write`, `node:http`, `node:dns`) now include async frames in stack traces. Debugging is significantly easier.

## Process Management & Zombie Defense

### Dev Server Management

Use `just` recipes for process control:
- `just dev` — starts server and watchers
- `just status` — checks running state

### The Zombie Problem

Bun file handles (especially SQLite DBs or SHM files) can persist if a process crashes hard. This causes "Disk I/O Errors" for future processes.

### Prevention

1. **Don't run GUI git watchers** — they hold `index.lock` and fight with CLI git
2. **Check `ps aux | grep bun`** before starting servers
3. **Kill stale processes** before critical operations
4. **Use `using` for resources** — ensures cleanup even on errors

## Standards & Patterns

1. **Use `Bun.$` for shell commands** — not `child_process`
2. **Use `Bun.file()` for file I/O** — not `node:fs` callbacks
3. **Use `Bun.cron()` for scheduling** — not external cron or node-cron
4. **Use `using` for disposable resources** — file handles, connections, views
5. **Use `glow` for reading markdown** — `bun ./file.md` for quick previews only
6. **Use `Bun.WebView` for browser automation** — not Playwright for simple tasks

## Validation

- `bun --version` returns 1.3.12+
- `bun test` passes
- `bun ./README.md` renders markdown to terminal
- `Bun.cron` available without errors
- `Bun.WebView` available on macOS without extra installs