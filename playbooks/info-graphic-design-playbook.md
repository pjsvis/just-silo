---
date: 2026-04-03
tags:
  - playbook
  - design
  - visualization
  - infographic
agent: any
environment: local
---

# Infographic Design Playbook

## Purpose
Produce a **designer-ready infographic specification** — wireframe, copy, visual hierarchy, and export details — without creating the actual graphic file.

## Context & Prerequisites

- **What you need:** Topic, key message, target audience, and use context (social/print/web)
- **What you output:** A structured specification document that a designer or tool can implement
- **What you DON'T output:** Final graphics, images, or production-ready files

## The Protocol

### Step 1: Elicit Requirements

Ask the user for:
1. **Topic** — What is the infographic about?
2. **Key Message** — One-sentence takeaway
3. **Target Audience** — Who reads this?
4. **Use Context** — Where will it live? (social media, print, web, presentation)
5. **Data** — Any statistics, timeline events, or list items to include?

*If the user hasn't provided data, ask for it before proceeding.*

### Step 2: Select Infographic Type

Choose ONE type based on the content:

| Type | Best For |
|------|----------|
| **Statistical** | Data-heavy: survey results, research, metrics |
| **Timeline** | Chronological: history, milestones, evolution |
| **Process** | How-to: workflows, tutorials, step-by-step |
| **Comparison** | Side-by-side: pros/cons, before/after, product vs product |
| **Geographic** | Location data: regional stats, travel routes |
| **Hierarchical** | Structure: org charts, taxonomies, decision trees |
| **List** | Ranked items: top 10, tips, resources |

### Step 3: Choose Dimensions

Based on use context:

**Social Media:**
| Platform | Size (px) | Orientation |
|----------|-----------|-------------|
| Instagram Post | 1080 x 1080 | Square |
| Instagram Story | 1080 x 1920 | Portrait |
| Pinterest | 1000 x 1500 | Portrait |
| Twitter/X | 1200 x 675 | Landscape |
| LinkedIn | 1200 x 627 | Landscape |
| Facebook | 1200 x 630 | Landscape |

**Print:**
| Size | Dimensions | Resolution |
|------|------------|------------|
| A4 | 2480 x 3508 px | 300 DPI |
| Letter | 2550 x 3300 px | 300 DPI |
| Poster A3 | 3508 x 4960 px | 300 DPI |

**Web:**
| Use | Width |
|-----|-------|
| Blog embed | 800px |
| Landing page | 1200px |
| Email | 600px |

### Step 4: Build the Specification

Use this output format:

```markdown
# Infographic Design Specification: [Title]

**Type**: [Selected type]
**Dimensions**: [Width x Height in px]
**Orientation**: [Portrait/Landscape/Square]
**Target Platform**: [Platform]

---

## Overview

- **Topic**: [Subject]
- **Key Message**: [One sentence]
- **Target Audience**: [Who]
- **Tone**: [Professional/Casual/Playful/etc.]

---

## Content Sections

### Header
- **Title**: [Text]
- **Subtitle**: [Supporting text]
- **Hero Element**: [Key stat or visual]

### Body Sections (numbered)
1. **[Section Name]**
   - Content: [Text]
   - Visual: [Chart/Icon/Image type]
   - Data: [Stats if any]

2. **[Section Name]**
   [Same structure]

### Footer
- **Call to Action**: [Text]
- **Source**: [Citations]
- **Branding**: [Logo placement]

---

## Layout Wireframe

```
[ASCII wireframe — see templates below]
```

---

## Visual Elements

### Icons Needed
1. [Icon]: [Purpose]

### Charts
1. [Type]: [Data]

---

## Color Palette

| Use | Color | Hex |
|-----|-------|-----|
| Primary | | # |
| Secondary | | # |
| Accent | | # |
| Background | | # |
| Text | | # |

---

## Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Title | | px | Bold |
| Headings | | px | Semibold |
| Body | | px | Regular |
| Stats | | px | Bold |

---

## Copy (Ready to Use)

### Title
```
[Exact text]
```

### [Section headings]
```
[Exact copy for each section]
```

---

## Design Notes

1. [Key consideration]
```

### Step 5: Include Relevant Template

#### Statistical Template
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

#### Timeline Template
```
┌─────────────────────────────────────┐
│           TITLE                     │
├─────────────────────────────────────┤
│  2020 ●───────────────────●        │
│        Event 1                      │
│                                     │
│  2021      ●──────────────●        │
│            Event 2                  │
│                                     │
│  2022           ●─────────●        │
│                 Event 3             │
├─────────────────────────────────────┤
│         Conclusion                  │
└─────────────────────────────────────┘
```

#### Process Template
```
┌─────────────────────────────────────┐
│           HOW TO [X]                │
├─────────────────────────────────────┤
│  ┌───┐                              │
│  │ 1 │  Step Title                  │
│  └───┘  Description text            │
│    │                                │
│    ▼                                │
│  ┌───┐                              │
│  │ 2 │  Step Title                  │
│  └───┘  Description text            │
│    │                                │
│    ▼                                │
│  ┌───┐                              │
│  │ 3 │  Step Title                  │
│  └───┘  Description text            │
├─────────────────────────────────────┤
│         Final Result                │
└─────────────────────────────────────┘
```

#### Comparison Template
```
┌─────────────────────────────────────┐
│           TITLE                     │
├────────────────┬────────────────────┤
│    OPTION A    │     OPTION B       │
├────────────────┼────────────────────┤
│  Feature 1: ✓  │  Feature 1: ✗      │
│  Feature 2: ✓  │  Feature 2: ✓      │
│  Price: $XX    │  Price: $XX        │
├────────────────┴────────────────────┤
│         Recommendation              │
└─────────────────────────────────────┘
```

#### List Template
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

1. **Visual Hierarchy:** Title largest → Key stats → Headings → Body → Sources smallest
2. **White Space:** Group related items, don't overcrowd
3. **Flow:** Guide eye top-to-bottom or left-to-right
4. **Consistency:** Uniform icon style, colors, typography

## Validation

The specification is complete when:
- [ ] Type selected and justified
- [ ] Dimensions match target platform
- [ ] All content sections have copy
- [ ] Wireframe template applied
- [ ] Color palette defined (5 colors max)
- [ ] Typography specified (max 3 fonts)
- [ ] Visual elements (icons, charts) listed
- [ ] Source citations included
- [ ] Design notes provided

## Limitations

- **Cannot:** Create actual graphics, generate images, produce final files
- **Can:** Produce specifications that designers or tools implement

---

*Source: Adapted from LobeHub infographic skill by claude-office-skills*
