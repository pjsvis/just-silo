# SUPERCEDED

The sub-agent model (agents/ directories with manifest.json, discovered via `just agents`) has been replaced by:

- **Harness-integrated tools** for cross-cutting concerns (e.g., `pr_watch`, `pr_fix_issues`)
- **Silo `process/` scripts** for domain-specific work
- **Direct justfile recipes** for everything else

The Simplicity Rule (extract to scripts, keep justfiles thin) is canonical in `playbooks/justfile-design-playbook.md`.

This document is preserved for historical reference.
