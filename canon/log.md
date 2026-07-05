# Canon Log

> Date-grouped change history for the `canon/` bundle. Newest first.
> Format: one bullet per change — what, where, why.

## 2026-07-05

- **Promoted** `analysis-playbook.md` → canonical status.
  *Why:* Founding entry. Distilled from a wargame conversation that exposed
  the false-precision failure mode (point probabilities without a calibration
  apparatus) and worked out the discipline that should have governed the
  output: declare the epistemic regime, use the qualitative likelihood
  ladder, ship a kill criterion with every branch, and treat research as a
  hunt for disconfirmation.
- **Established** the `canon/` OKF bundle at repo root.
  *Why:* `playbooks/` is consumed internally (how just-silo operates);
  `canon/` is curated for external publication (what just-silo offers other
  silos). Peers at root, not parent-child. The two are different functions —
  one is operations, one is curation — and the directory boundary makes that
  explicit.
- **Adopted** INDEX.jsonl as the registry source of truth, `index.md` as a
  generated artifact, per the registry pattern established in `blog-posts`.
  *Why:* Avoids hand-maintaining two parallel stores; the JSONL is
  authoritative, the markdown is derived.
