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
- google-docs-pick.sh
- google-docs-pull.sh
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

### Targeted Google Docs pull (single file)

Use this when you want to import specific docs into the project (instead of mirroring full folders).

- Pull one file to scratch:
  - `./scripts/google-docs-pull.sh --source "gdrive:Specs/My Doc" --dest "scratch/google-docs-imports/my-doc.md"`

- Dry run:
  - `./scripts/google-docs-pull.sh --source "gdrive:Specs/My Doc" --dest "scratch/google-docs-imports/my-doc.md" --dry-run`

- Pull directly into briefs:
  - `./scripts/google-docs-pull.sh --source "gdrive:Specs/Brief 2026-04-21" --dest "briefs/2026-04-21-brief-my-topic.md"`

- Pull and refresh QMD:
  - `./scripts/google-docs-pull.sh --source "gdrive:Playbooks/New Playbook" --dest "playbooks/new-playbook.md" --refresh-qmd`

### Interactive Google Docs picker (gum)

Use this when you want an extension-first, filterable list from Google Drive, then select one file to import.

- Start picker at remote root:
  - `./scripts/google-docs-pick.sh`

- Start picker in a specific remote subpath:
  - `./scripts/google-docs-pick.sh --path briefs`
  - `./scripts/google-docs-pick.sh --path "Specs/Product"`

- Start directly in DOCX mode:
  - `./scripts/google-docs-pick.sh --ext docx`

- Pull selected file and refresh QMD:
  - `./scripts/google-docs-pick.sh --refresh-qmd`

- Dry run:
  - `./scripts/google-docs-pick.sh --dry-run`

Cache behavior:
- Picker caches remote file listings for faster startup.
- Cache key is based on remote + path.
- Default cache location: `scratch/cache/google-docs-picker`
- Default cache TTL: 900 seconds (15 minutes)

Cache controls:
- Force refresh from remote:
  - `./scripts/google-docs-pick.sh --refresh-cache`
- Disable cache for one run:
  - `./scripts/google-docs-pick.sh --no-cache`
- Set custom TTL:
  - `./scripts/google-docs-pick.sh --cache-ttl 300`
- Set custom cache directory:
  - `./scripts/google-docs-pick.sh --cache-dir scratch/cache/google-docs-picker`

Top-up behavior:
- Top-up merges additional rows from a narrower subpath into existing cache.
- Useful when full remote scans are slow and you want to enrich cache incrementally.
- Example:
  - `./scripts/google-docs-pick.sh --topup "briefs/2026"`

The picker now:
1. Prompts for file extension first (DOCX-first workflow supported)
2. Loads cached listing when fresh, otherwise refreshes from remote
3. Optionally tops up cache from a narrower remote subpath
4. Lists only files matching selected extension (or `all`)
5. Uses `gum filter` to narrow and select one file
6. Prompts for destination (repo-relative)
7. Delegates import to `google-docs-pull.sh`

### Dedicated DOCX → Markdown picker (multi-select + downloaded tracking)

Use this dedicated workflow when you want to:
- list `.docx` files only,
- select multiple files,
- pull them as `.md`,
- and hide files already downloaded by default.

Script:
- `./scripts/google-docs-pick-docx-md.sh`

Examples:
- Default run (hide already-downloaded, auto-sanitize on):
  - `./scripts/google-docs-pick-docx-md.sh`
- Scope to a remote subpath:
  - `./scripts/google-docs-pick-docx-md.sh --path briefs`
- Include already-downloaded rows:
  - `./scripts/google-docs-pick-docx-md.sh --show-downloaded`
- Top-up cache from a narrower path:
  - `./scripts/google-docs-pick-docx-md.sh --topup "briefs/2026"`
- Pull and refresh QMD:
  - `./scripts/google-docs-pick-docx-md.sh --refresh-qmd`
- Disable auto-sanitization for a run:
  - `./scripts/google-docs-pick-docx-md.sh --no-sanitize`

Behavior:
1. Loads listing cache (or refreshes) for the selected remote/path
2. Filters source candidates to `.docx`
3. Marks each row as `NEW` or `DOWNLOADED` (from manifest)
4. Hides downloaded rows by default
5. Supports interactive multi-select
6. Pulls each selected source as markdown (`--output-ext md`)
7. Auto-sanitizes each successfully imported markdown file by default
8. Appends per-item pull results to manifest

Tracking manifest:
- `scratch/cache/google-docs-picker/downloaded.jsonl`

Cache files:
- `scratch/cache/google-docs-picker/<cache-key>.tsv`

### just recipes

- `just gdocs-sync`
- `just gdocs-sync-dry-run`
- `just gdocs-sync-config`
- `just gdocs-pull "<source>" "<dest>"`
- `just gdocs-pull-dry-run "<source>" "<dest>"`
- `just gdocs-pull-refresh "<source>" "<dest>"`
- `just gdocs-pick`
- `just gdocs-pick-docx`
- `just gdocs-pick-path "<remote_subpath>"`
- `just gdocs-pick-refresh-cache`
- `just gdocs-pick-topup "<remote_subpath>"`
- `just gdocs-pick-docx-md`
- `just gdocs-pick-docx-md-all`
- `just gdocs-pick-docx-md-path "<remote_subpath>"`
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

