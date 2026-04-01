#!/usr/bin/env bun

import { readFileSync, existsSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

interface SiloManifest {
  name: string;
  version: string;
  description: string;
  created: string;
  owner: string;
  phases: string[];
  interface: {
    engine: string;
    schema: string;
    [key: string]: string;
  };
}

const loadSilo = (name: string): SiloManifest | null => {
  const path = `silo_${name}/.silo`;
  if (!existsSync(path)) {
    console.log(`❌ Silo "${name}" not found`);
    return null;
  }
  return JSON.parse(readFileSync(path, "utf-8"));
};

const getSiloAge = (created: string): string => {
  const days = Math.floor((Date.now() - new Date(created).getTime()) / 86400000);
  return `${days}d ago`;
};

const main = () => {
  const siloName = process.argv[2] ?? "barley";
  const manifest = loadSilo(siloName);

  if (!manifest) return;

  console.log(`\n📦 ${manifest.name} v${manifest.version}`);
  console.log(`   ${manifest.description}`);
  console.log(`   Created: ${manifest.created} (${getSiloAge(manifest.created)})`);
  console.log(`   Owner: ${manifest.owner}`);
  console.log(`   Phases: ${manifest.phases.join(" → ")}`);
};

main();
