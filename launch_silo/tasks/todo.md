# Launch Prep Task

## Objective

Generate social media content for just-silo launch.

## Requirements

1. Read targets from `context/targets.md`
2. Generate 3 draft posts (HN, X, Reddit)
3. Present drafts via glow for human review
4. Use gum for selection and confirmation
5. On approval, write to `output/final_launch_schedule.json`

## Output Format

```json
{
  "timestamp": "ISO-8601",
  "draft": "selected draft content",
  "channel": "HN|X|Reddit",
  "vibe": "optional user tag",
  "status": "approved"
}
```

## Fail-Shut Rules

- If human rejects → log to `logs/audit.log` → exit
- Do NOT attempt to "reason" past rejection
- Log all gum/glow interactions
