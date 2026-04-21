## Assistant

Implemented. I set up the **recommended rclone-based Google Docs pipeline** and wired it into your existing QMD workflow.

## What I added

### New sync script
- `scripts/google-docs-sync.sh`
  - Syncs Google Drive folders into:
    - `briefs/`
    - `debriefs/`
    - `briefs_archive/`
    - `debriefs_archive/`
  - Uses staging dirs before promoting to local folders
  - Supports:
    - `--dry-run`
    - `--only <collection>`
    - `--no-qmd-refresh`
    - `--print-config`
    - `--config <env-file>`
  - Runs `just qmd-refresh` after successful sync (unless disabled)

### Config template
- `scripts/google-docs-sync.env.example`
- I also created:
  - `scripts/google-docs-sync.env` (copied from example, safe defaults)

### Just recipes
- `just gdocs-sync`
- `just gdocs-sync-dry-run`
- `just gdocs-sync-config`

(Existing `qmd-*` + `watch-qmd` + health checks are still in place.)

### Documentation
- Updated `scripts/README.md` with setup + runbook for this workflow.

---

## What I validated

- Installed `rclone` via Homebrew.
- Verified recipes show up in `just --list`.
- Ran:
  - `just gdocs-sync-dry-run`
- Dry-run succeeded end-to-end (no mutations), showing all planned sync/promote/QMD-refresh steps.

---

## What you need to do next (one-time)

1. Configure your Google Drive remote in rclone:
   - `rclone config`
   - create remote name `gdrive` (or change `RCLONE_REMOTE` in env file)

2. Edit:
   - `scripts/google-docs-sync.env`
   - set correct `RCLONE_BASE_PATH` / `REMOTE_*_SUBPATH` mappings

3. Optional safety:
   - set `MIN_FILES_*` thresholds > 0 to avoid accidental empty promotions

4. Run:
   - `just gdocs-sync-dry-run`
   - then `just gdocs-sync`

If you want, I can now walk you step-by-step through `rclone config` choices specifically for your least-privilege/local workflow (recommended scopes and options).

## User

- please do

## Assistant

Excellent — here’s the **exact setup path** I recommend for your workflow.

## 1) Create a least-privilege `rclone` remote

Run `rclone config` and choose:

1. `n` (new remote)  
2. name: `gdrive`  
3. storage: `drive`  
4. `client_id` / `client_secret`:
   - best: use your own Google OAuth client
   - okay for testing: leave blank
5. scope: choose `drive.readonly` (**recommended** for your sync-only workflow)
6. service account file: leave blank (unless you intentionally use SA)
7. advanced config: `n` (for now)
8. auto config: `y` (if local machine has browser)
9. authorize
10. shared drive question:
   - `n` if your folders are in My Drive
   - `y` if they live in a Shared Drive
11. save remote

Why `drive.readonly` is ideal here: your script only pulls docs from Drive into local folders, so read-only tokens reduce risk.

---

## 2) Verify the remote works

Run these checks:

- `rclone listremotes` (confirm `gdrive:` exists)
- `rclone lsd gdrive:` (list top-level directories)
- if needed: `rclone lsd gdrive:some/path`

If these fail, fix auth before proceeding.

---

## 3) Configure repo mapping

Edit `scripts/google-docs-sync.env` and set:

- `RCLONE_REMOTE=gdrive`
- `RCLONE_BASE_PATH=` (optional; set if all your docs live under a common parent folder)
- `REMOTE_BRIEFS_SUBPATH=...`
- `REMOTE_DEBRIEFS_SUBPATH=...`
- `REMOTE_BRIEFS_ARCHIVE_SUBPATH=...`
- `REMOTE_DEBRIEFS_ARCHIVE_SUBPATH=...`

Also set safety thresholds once paths are right, e.g.:
- `MIN_FILES_BRIEFS=3`
- `MIN_FILES_DEBRIEFS=1`
- etc.

That gives you a guardrail against accidental empty syncs.

---

## 4) Dry-run first, then real sync

- `just gdocs-sync-config` (confirm resolved config)
- `just gdocs-sync-dry-run` (no file changes)
- `just gdocs-sync` (real sync + QMD refresh)

---

## 5) Daily workflow

- Pull latest docs: `just gdocs-sync`
- Validate retrieval health: `just qmd-health-check`
- Keep QMD hot during active local edits: `just watch-qmd`

---

## 6) Optional hardening (recommended later)

If you want stronger separation:
- create a dedicated Google account/client for this pipeline
- use a dedicated Drive folder as `RCLONE_BASE_PATH`
- keep `drive.readonly` scope
- never run with write scopes unless needed

---

If you want, next I can help you fill `scripts/google-docs-sync.env` interactively: you run `rclone lsd` in a few paths and I’ll map exact `REMOTE_*_SUBPATH` values with you.

