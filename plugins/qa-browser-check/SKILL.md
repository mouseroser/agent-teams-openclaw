---
name: qa-browser-check
description: Run a focused browser-based QA pass for UI, workflow, and end-to-end tasks. Use when changes affect screens, user flows, publishing steps, forms, dashboards, login-dependent workflows, or automation that must be validated through the browser, especially after review-gate or before release.
---

# QA Browser Check

## Overview

Use this skill to turn “please test it in the browser” into a focused QA pass with explicit target flows, expected outcomes, and bug reporting. The job is not broad exploration. The job is to validate the key path, catch regressions, and return clear failure evidence with next actions.

## Good fits

Use this skill for:
- UI changes
- multi-step workflows
- browser-visible feature delivery
- dashboards, forms, and settings pages
- publishing or creator workflows
- login-dependent checks where local browser state matters

Do not use it for:
- backend-only changes with no browser-visible behavior
- conceptual review with no runnable flow
- broad exploratory testing with no defined target path

## Output contract

Produce a QA note with these sections:
- Target flow
- Environment / browser path used
- Result
- Evidence
- Bugs found
- Recommended next step

Possible results:
- Pass
- Pass with caveats
- Fail
- Blocked by environment

## Testing principle

Prefer one strong, realistic user flow over many shallow clicks.

The check should answer:
- can the intended user complete the key flow?
- does the observed behavior match the reviewed plan?
- where exactly does it break?
- what should the builder fix first?

## Workflow

### Step 1 — Define the target flow

Before clicking anything, write down:
- start state
- user goal
- critical path steps
- expected result

If there is no clear target flow, ask for one or infer the most business-critical path.

### Step 2 — Pick the right browser context

Prefer the existing OpenClaw browser stack.
Use the logged-in user/browser profile when cookies, sessions, or creator-platform access matter.
Do not switch browser stacks without a reason.

### Step 3 — Validate the main path

Run the shortest realistic sequence that proves or disproves the feature.
Capture:
- where the flow starts
- key interaction points
- observed outputs or failures

### Step 4 — Check the most likely regression edge

After the main path, test the single most likely adjacent failure:
- validation edge case
- state persistence issue
- wrong redirect
- missing save/apply action
- modal/dialog/permission break

### Step 5 — Report crisply

If the flow passes, say what was proven.
If it fails, report:
- exact failing step
- expected vs actual behavior
- visible error or broken state
- likely fix direction if obvious

## Bug reporting rules

A good QA bug report includes:
- page or flow name
- exact step that failed
- expected behavior
- actual behavior
- severity on the target flow

Avoid vague reports like “seems broken.”

## Example triggers

- “帮我做一次 browser QA”
- “这个 UI 改动过 review 了，再跑一遍关键路径”
- “发布流程改了，帮我验证主链有没有断”
- “先在浏览器里走一遍，再决定能不能 release”
