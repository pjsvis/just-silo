# Phone Voice Control Setup

## Overview

Use your iPhone as a voice remote to control PXY (Gemma 4). No touching the MacBook.

## Setup

### 1. Start PXY Voice Session

On your iPhone, open the AI assistant app and start a voice session with PXY.

### 2. Load Presentation Context

Paste this into the session:

```
Here is the presentation context:
- Station ID: Grumpy
- Slides are in: presentation/slides/
- Commands: ./slide <name> or ./push "<markdown>"
- Start with: self-test
```

### 3. Test Commands

Try these voice commands:

```
"PXY, self-test"
"PXY, show slide 1"
"PXY, show grumpy definition"
"PXY, what is the cost for 10k files?"
```

### 4. During Presentation

The flow:

1. Audience asks question
2. Presenter: "Good question — PXY, show us..."
3. PXY generates and pushes content
4. Content appears on projector
5. Presenter interprets
6. Presenter: "PXY, back to slides" or "PXY, show slide N"

## Voice Commands Reference

| Command | Action |
|---------|--------|
| `self-test` | Confirm systems nominal |
| `slide N` | Show slide by number |
| `slide <name>` | Show slide by name |
| `grumpy` | Show station identifier |
| `push # Hello` | Push arbitrary markdown |
| `next` | (Future) Next slide |
| `back` | (Future) Previous slide |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| PXY doesn't respond | Check iPhone session is active |
| Content not appearing | Check server is running |
| Voice not recognized | Speak clearly, reduce background noise |

## Alternative: Wispr Flow

If voice session isn't working, use Wispr Flow on Mac:

1. Open Wispr Flow
2. Dictate command
3. Press Enter to send
4. PXY executes

## See Also

- `briefs/2026-04-08/2026-04-08-pxy-presentation-workflow.md`
- `briefs/2026-04-08/2026-04-08-sse-presentation-server.md`
