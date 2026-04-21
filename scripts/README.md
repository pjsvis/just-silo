# scripts/

## Contents
- README.md
- about.sh
- agent-create.sh
- agent-invoke.sh
- agent-status.sh
- blog-generate.sh
- briefs.sh
- dev-check.sh
- google-docs-sync.env.example
- google-docs-sync.sh
- help.sh
- qmd-health-check.sh
- qmd-refresh.sh
- watch-qmd.sh
- lab


## Subdirectories
- lab

---

## Google Docs Sync Workflow (rclone + QMD)

This repository includes a local-first Google Docs sync workflow designed to feed `briefs`/`debriefs` collections into QMD.

### Scripts

- `google-docs-sync.sh` — syncs Google Drive folders into local markdown directories using staged promotion
- `google-docs-sync.env.example` — example config file for remote names and folder mappings
- `qmd-refresh.sh` — refreshes QMD index + embeddings for volatile collections
- `qmd-health-check.sh` — validates QMD collections, vectors, and sentinel query behavior
- `watch-qmd.sh` — watches volatile markdown folders and triggers QMD refresh on changes

### One-time setup

1. Install dependencies:
   - `rclone`
   - `qmd`
   - `just`
   - `watchexec` (optional, for watch mode)

2. Configure `rclone` with a Google Drive remote (example remote name: `gdrive`).

3. Create a local sync config:
   - Copy `scripts/google-docs-sync.env.example` to `scripts/google-docs-sync.env`
   - Edit:
     - `RCLONE_REMOTE`
     - `RCLONE_BASE_PATH` (optional)
     - `REMOTE_*_SUBPATH` mappings
     - optional safety thresholds (`MIN_FILES_*`)

### Typical usage

- Dry run:
  - `./scripts/google-docs-sync.sh --config scripts/google-docs-sync.env --dry-run`

- Sync all collections + refresh QMD:
  - `./scripts/google-docs-sync.sh --config scripts/google-docs-sync.env`

- Sync one collection only:
  - `./scripts/google-docs-sync.sh --config scripts/google-docs-sync.env --only briefs`

- Skip QMD refresh:
  - `./scripts/google-docs-sync.sh --config scripts/google-docs-sync.env --no-qmd-refresh`

- Show resolved config:
  - `./scripts/google-docs-sync.sh --config scripts/google-docs-sync.env --print-config`

### just recipes

- `just qmd-refresh`
- `just qmd-refresh-dry-run`
- `just qmd-status`
- `just qmd-health-check`
- `just qmd-health-check-json`
- `just watch-qmd`

### Recommended operational loop

1. Pull/sync docs from Google Drive:
   - `./scripts/google-docs-sync.sh --config scripts/google-docs-sync.env`
2. Verify retrieval health:
   - `just qmd-health-check`
3. Run continuous local refresh during active editing:
   - `just watch-qmd`

### Safety notes

- Keep `RCLONE_EXPORT_FORMATS` with `md` first for best QMD results.
- Use `MIN_FILES_*` safeguards to catch accidental empty sync targets.
- Do not commit secrets; rclone credentials stay in rclone’s own config store.

