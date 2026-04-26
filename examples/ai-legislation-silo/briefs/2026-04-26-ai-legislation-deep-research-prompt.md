---
date: 2026-04-26
tags: [brief, research, ai-legislation, prompt, acquisition]
---

# Brief: Deep Research Prompt — AI Adjacent Legislative Documents

## Goal

Produce a comprehensive, ordered list of AI-adjacent legislative and regulatory documents across jurisdictions (EU, UK, Scotland, US, international). Order by **ease of acquisition** and **ease of processing**.

## The Prompt

> You are a legal research assistant specializing in AI governance and technology regulation.
>
> Produce a comprehensive list of **legislative and regulatory documents** that are adjacent to or directly governing AI systems. This includes:
>
> ### Categories
> 1. **Primary AI Legislation** — Laws whose primary purpose is AI governance
>    - EU AI Act (Regulation 2024/1689)
>    - Proposed US federal AI legislation
>    - National AI strategies with legislative force
>
> 2. **Data Protection & Privacy** — Applies to AI by extension
>    - GDPR (EU)
>    - UK Data Protection Act 2018
>    - US state privacy laws (CCPA, etc.)
>
> 3. **Sector-Specific Regulation** — AI used in regulated domains
>    - Medical device regulation (AI/ML as SaMD)
>    - Financial services (algorithmic trading, credit scoring)
>    - Automotive (autonomous vehicles)
>
> 4. **Intellectual Property** — AI and copyright/patent
>    - Proposed EU AI copyright directives
>    - US Copyright Office AI guidance
>
> 5. **Liability & Accountability**
>    - EU Product Liability Directive revisions
>    - Proposed AI liability frameworks
>
> 6. **International & Soft Law**
>    - OECD AI Principles
>    - UNESCO AI Ethics Recommendation
>    - G7/G20 AI declarations
>
> ### For Each Document, Provide:
> | Field | Description |
> |-------|-------------|
> | **Jurisdiction** | EU, UK, Scotland, US Federal, US State, International |
> | **Name** | Full formal name |
> | **Type** | Regulation, Directive, Act, Guidance, Strategy, White Paper |
> | **Status** | In force, Proposed, Draft, Enacted (not yet in force) |
> | **Date** | Publication / entry into force |
> | **AI-Specific?** | Yes (primary purpose) / Adjacent (applies to AI) |
> | **Format Available** | PDF, HTML, DOCX, Plain text, Proprietary |
> | **Source URL** | Official source if known |
> | **Size Estimate** | Pages / word count if known |
> | **Ease of Acquisition** | 1-5 (1 = direct download, 5 = paywalled/fragmented) |
> | **Ease of Processing** | 1-5 (1 = clean HTML/PDF, 5 = scanned images/poor OCR) |
> | **Priority** | Derived: Low Ease × High Relevance = Do First |
>
> ### Ordering
> Sort by: `(Ease of Acquisition + Ease of Processing) / 2` ascending, then by relevance descending.
>
> ### Output Format
> Return as a structured markdown table, followed by a JSONL block for machine processing.
>
> ### Constraints
> - Focus on **official sources** (EUR-Lex, legislation.gov.uk, Federal Register, etc.)
> - Note **language availability** (English required for our pipeline)
> - Flag **consolidated versions** vs original versions
> - Identify **amendments** and **repeals** that affect current applicability
