---
name: founder-office-hours
description: Run a lightweight founder/CEO-style product framing pass before planning or building. Use when a request involves product direction, feature shaping, scope cuts, user-value questions, wedge definition, prioritization, or “should we build this at all?” decisions, especially before starchain, autoplan-lite, or medium-to-large coding work.
---

# Founder Office Hours

## Overview

Use this skill to sharpen a request before execution. The job is not to produce an implementation plan yet; the job is to decide whether the problem is worth solving, what the smallest valuable version is, what should be cut, and what decision the human actually needs to make.

## Good fits

Use this skill for:
- new product ideas
- medium or large feature proposals
- feature requests with unclear user value
- “should we build this?” decisions
- requests that feel too broad, fuzzy, or overbuilt
- pre-planning work before `autoplan-lite` or a heavier pipeline

Do not use it for:
- tiny implementation details
- already-well-scoped execution tasks
- pure bug fixes with obvious scope
- final engineering sequencing

## Output contract

Produce a concise framing note with these sections:
- Core problem
- Who benefits
- Why now
- Smallest useful wedge
- Scope to cut
- Key tradeoffs
- Decision recommendation
- Open questions for the human

The output should help the human choose or refine a direction. Do not turn this into an implementation checklist.

## Core lens

Think like a strong founder or product lead:
- What user pain is real here?
- Is this a valuable wedge or just more surface area?
- What is the cheapest version that creates signal?
- What should be explicitly cut to keep momentum?
- What makes this worth doing now instead of later?

Prefer sharper scope over broader ambition.

## Workflow

### Step 1 — Restate the real decision

Rewrite the request as a decision, not just a feature idea.

Examples:
- not “build X dashboard”
- but “decide whether X dashboard is the right minimal lever for visibility into Y”

### Step 2 — Identify user and value

Clarify:
- primary user or operator
- concrete pain or frustration
- desired behavior change or operational gain
- why current alternatives are insufficient

If user value is weak or abstract, say so directly.

### Step 3 — Define the smallest wedge

Find the minimal version that would still create meaningful learning, value, or leverage.

Ask:
- what is the smallest useful version?
- what can be postponed safely?
- what would make this feel obviously overbuilt?

### Step 4 — Cut scope aggressively

Name the parts that should not be in v1.

Good cuts include:
- admin surfaces
- analytics before core usage exists
- settings for hypothetical future needs
- automation layers before manual value is proven
- multi-role support when one operator path is enough

### Step 5 — Surface tradeoffs and timing

Identify the most important tradeoffs:
- speed vs completeness
- leverage vs polish
- signal vs certainty
- operator convenience vs user impact

Also ask whether the work is worth doing now.

### Step 6 — Recommend a decision

End with one of these recommendations:
- build the wedge now
- shrink and build
- defer
- reject
- gather one missing input first

Be decisive unless uncertainty is truly blocking.

## Handoff guidance

If the decision is “build” or “shrink and build,” hand off naturally into `autoplan-lite` or a heavier planning lane.

If the answer is “defer” or “reject,” say why clearly so the human can trust the cut.

## Example triggers

- “这个想法值不值得做？”
- “先别规划实现，先帮我做产品打磨”
- “这个功能 scope 太大了，帮我砍到最小可做版本”
- “站在 founder 视角看，这个到底是不是现在该做的事？”
