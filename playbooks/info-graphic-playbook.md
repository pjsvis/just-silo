---
date: 2026-04-03
tags:
  - playbook
  - design
  - visualization
  - infographic
agent: any
environment: local
source: claude-office-skills/skills (infographic)
---

# Infographic Design Playbook

## Purpose
Produce a **designer-ready infographic specification** — wireframe, copy, visual hierarchy, dimensions — that a designer or tool can implement.

**Output:** Structured specification document  
**NOT output:** Final graphics, images, production files

## Step 1: Elicit Requirements

Ask for:
1. **Topic** — What is this about?
2. **Key Message** — One-sentence takeaway
3. **Target Audience** — Who reads this?
4. **Use Context** — Where? (social/print/web)
5. **Data** — Stats, events, steps, or list items to include?

*If data is missing, request it before proceeding.*

## Step 2: Select Type

Match content type to ONE category:

| Type | Use When |
|------|----------|
| **Statistical** | Data-heavy: surveys, research, metrics, KPIs |
| **Timeline** | Chronological: history, milestones, evolution |
| **Process** | Sequential: how-to, workflows, tutorials |
| **Comparison** | Side-by-side: pros/cons, before/after, vs |
| **Geographic** | Location: regional data, routes |
| **Hierarchical** | Structure: org charts, taxonomies |
| **List** | Ranked: top N, tips, resources |

## Step 3: Set Dimensions

### Social Media
| Platform | Size | Orientation |
|----------|------|-------------|
| Instagram Post | 1080×1080 | Square |
| Instagram Story | 1080×1920 | Portrait |
| Pinterest | 1000×1500 | Portrait |
| Twitter/X | 1200×675 | Landscape |
| LinkedIn | 1200×627 | Landscape |

### Print (300 DPI)
| Size | Dimensions |
|------|------------|
| A4 | 2480×3508 px |
| Letter | 2550×3300 px |
| A3 Poster | 3508×4960 px |

### Web
| Use | Width |
|-----|-------|
| Blog | 800px |
| Landing | 1200px |
| Email | 600px |

## Step 4: Build Specification

Produce this document:

```markdown
# Infographic Design Specification: [Title]

**Type**: [Selected]
**Dimensions**: [Width × Height px]
**Orientation**: [Portrait/Landscape/Square]
**Target Platform**: [Platform]

---

## Overview
- **Topic**: [Subject]
- **Key Message**: [One sentence]
- **Audience**: [Who]
- **Tone**: [Professional/Casual/etc.]

---

## Content Sections

### Header
- **Title**: [Text]
- **Subtitle**: [Text]
- **Hero**: [Key stat or visual]

### Body (numbered)
1. **[Section Name]**
   - Content: [Text]
   - Visual: [Chart/Icon/Image]
   - Data: [Stats if any]

### Footer
- **CTA**: [What to do next]
- **Source**: [Citations]
- **Branding**: [Logo placement]

---

## Wireframe
```
[Apply template from Step 5]
```

---

## Visual Elements
- **Icons**: [List with purpose]
- **Charts**: [Type and data]
- **Images**: [Description]

---

## Color Palette
| Role | Hex |
|------|-----|
| Primary | # |
| Secondary | # |
| Accent | # |
| Background | # |
| Text | # |

---

## Typography
| Element | Size | Weight |
|---------|------|--------|
| Title | px | Bold |
| Headings | px | Semibold |
| Body | px | Regular |
| Stats | px | Bold |

---

## Copy
### Title
```
[Exact text]
```
[Repeat for each section]

---

## Design Notes
1. [Key consideration]
2. [Key consideration]
```

## Step 5: Apply Template

### Statistical
```
┌─────────────────────────────────────┐
│           HEADER/TITLE              │
│         Key Statistic Hero          │
├─────────────────────────────────────┤
│   ┌─────┐  ┌─────┐  ┌─────┐        │
│   │ KPI │  │ KPI │  │ KPI │        │
│   └─────┘  └─────┘  └─────┘        │
├─────────────────────────────────────┤
│         Main Chart/Graph            │
├─────────────────────────────────────┤
│   Supporting stats with icons       │
├─────────────────────────────────────┤
│         Call to Action              │
│            Source/Logo              │
└─────────────────────────────────────┘
```

### Timeline
```
┌─────────────────────────────────────┐
│           TITLE                     │
├─────────────────────────────────────┤
│  Year ●──────────────●              │
│       Event 1                        │
│                                     │
│       ●──────────────● Event 2      │
│                                     │
│            ●────────● Event 3       │
├─────────────────────────────────────┤
│         Conclusion                  │
└─────────────────────────────────────┘
```

### Process
```
┌─────────────────────────────────────┐
│           HOW TO [X]                │
├─────────────────────────────────────┤
│  ┌───┐                              │
│  │ 1 │  Step Title                  │
│  └───┘  Description                 │
│    │                                │
│    ▼                                │
│  ┌───┐                              │
│  │ 2 │  Step Title                  │
│  └───┘  Description                 │
│    │                                │
│    ▼                                │
│  ┌───┐                              │
│  │ 3 │  Step Title                  │
│  └───┘                              │
├─────────────────────────────────────┤
│         Final Result                │
└─────────────────────────────────────┘
```

### Comparison
```
┌─────────────────────────────────────┐
│           TITLE                     │
├────────────────┬────────────────────┤
│    OPTION A    │     OPTION B       │
├────────────────┼────────────────────┤
│  Feature 1: ✓  │  Feature 1: ✗      │
│  Feature 2: ✓  │  Feature 2: ✓      │
│  Feature 3: ✗  │  Feature 3: ✓      │
│  Price: $XX    │  Price: $XX        │
├────────────────┴────────────────────┤
│         Recommendation              │
└─────────────────────────────────────┘
```

### List
```
┌─────────────────────────────────────┐
│         TOP N [TOPIC]               │
├─────────────────────────────────────┤
│  🥇 #1  Title                       │
│         Description                 │
├─────────────────────────────────────┤
│  🥈 #2  Title                       │
│         Description                 │
├─────────────────────────────────────┤
│  🥉 #3  Title                       │
│         Description                 │
├─────────────────────────────────────┤
│  [Continue...]                      │
└─────────────────────────────────────┘
```

## Design Principles

1. **Hierarchy:** Title > Stats > Headings > Body > Sources
2. **White Space:** Don't overcrowd; group related items
3. **Flow:** Guide eye top→bottom or left→right
4. **Consistency:** Uniform icons, colors, typography

## Tips

1. Lead with the most interesting data (hook)
2. One main message per infographic
3. Round numbers; highlight key figures
4. Use visual metaphors for abstract concepts
5. Cite sources; add logo/brand

## Validation Checklist

- [ ] Type selected
- [ ] Dimensions match platform
- [ ] All content sections have copy
- [ ] Template applied
- [ ] ≤5 colors defined
- [ ] ≤3 fonts specified
- [ ] Icons/charts listed
- [ ] Sources cited
- [ ] Design notes included

## Limitations

- **Cannot:** Create graphics, generate images, produce final files
- **Can:** Produce specifications for designers or tools

---

*Source: Adapted from LobeHub infographic skill v1.0.0 by claude-office-skills*
