#!/usr/bin/env bun

import { spawnSync } from "node:child_process";

interface DepCheck {
  name: string;
  command: string;
  required: boolean;
}

interface DepResult {
  name: string;
  status: "✅" | "❌" | "⚠️";
  message: string;
}

const CORE_DEPS: DepCheck[] = [
  { name: "just", command: "just --version", required: true },
  { name: "bun", command: "bun --version", required: true },
  { name: "jq", command: "jq --version", required: false },
];

const OPTIONAL_DEPS: DepCheck[] = [
  { name: "watchexec", command: "watchexec --version", required: false },
];

const AGENTS: DepCheck[] = [
  { name: "pi", command: "pi -p 'test'", required: false },
  { name: "claude", command: "claude -p 'test'", required: false },
  { name: "ollama", command: "ollama list", required: false },
];

const checkDep = (dep: DepCheck): DepResult => {
  const [cmd, ...args] = dep.command.split(" ");
  try {
    const result = spawnSync(cmd, args, { timeout: 5000 });
    const output = result.stdout?.toString().trim() || result.stderr?.toString().trim() || "";
    
    // Detect auth issues
    if (output.includes("Not logged in") || output.includes("login")) {
      return { name: dep.name, status: "⚠️", message: "Installed but needs auth" };
    }
    
    return { name: dep.name, status: "✅", message: output.split("\n")[0] };
  } catch {
    return { name: dep.name, status: "❌", message: "Not found" };
  }
};

const main = () => {
  const silo = process.argv[2] ?? ".";
  console.log(`\n📦 Dependency Check: ${silo}\n`);

  console.log("Core (required):");
  for (const dep of CORE_DEPS) {
    const result = checkDep(dep);
    const icon = dep.required ? result.status : result.status;
    console.log(`  ${result.status} ${dep.name}: ${result.message}`);
  }

  console.log("\nOptional:");
  for (const dep of OPTIONAL_DEPS) {
    const result = checkDep(dep);
    console.log(`  ${result.status} ${dep.name}: ${result.message}`);
  }

  console.log("\nAgents (optional):");
  for (const agent of AGENTS) {
    const result = checkDep(agent);
    console.log(`  ${result.status} ${agent.name}: ${result.message}`);
  }

  console.log("\nLegend:");
  console.log("  ✅ Installed and working");
  console.log("  ⚠️  Installed but needs auth/setup");
  console.log("  ❌ Not installed (pipelines may use fallback)");
};

main();
