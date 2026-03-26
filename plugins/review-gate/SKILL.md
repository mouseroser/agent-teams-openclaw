---
name: review-gate
description: Run a stricter post-build review gate before declaring a task done. Use when code, workflow logic, automation, or configuration changes need a structured review for correctness, regression risk, completeness, testing gaps, and rollout concerns, especially after coding work and before QA, docs sync, or release.
---

# Review Gate

## Overview

Use this skill to convert a loose “please review this” into a clear go/no-go quality gate. The review should not stop at style or surface comments. It should decide whether the work is actually correct, complete enough, safe enough to continue, and what must happen next.

## Good fits

Use this skill for:
- completed coding tasks
- workflow or automation changes
- configuration edits with operational risk
- UI or product work before QA/browser checks
- any task where “looks done” is not a reliable standard

Do not use it for:
- brainstorming before code exists
- trivial typo-only changes
- tasks where the only review needed is proofreading

## Output contract

Produce a concise review gate result with these sections:
- Verdict
- What was reviewed
- Correctness concerns
- Regression risks
- Completeness gaps
- Required tests or validations
- Recommended next step

Use verdicts such as:
- Pass
- Pass with follow-ups
- Needs fixes before QA
- Blocked

## Review standard

Review for:
- correctness
- regression risk
- hidden side effects
- missing edge cases
- mismatch between requested scope and delivered scope
- validation and test coverage gaps
- rollout or operational hazards

Do not optimize for politeness over truth.

## Workflow

### Step 1 — Restate the intended outcome

State what the change claims to accomplish and what success should mean.

### Step 2 — Inspect for correctness

Ask:
- does the change actually solve the stated problem?
- are there logic holes or broken assumptions?
- does the implementation contradict constraints or prior architecture?

### Step 3 — Inspect for regression risk

Ask:
- what nearby behavior could break?
- what existing flows depend on these files or decisions?
- what is fragile or easy to overlook?

### Step 4 — Inspect for completeness

Ask:
- is any required follow-up missing?
- are docs, tests, migrations, prompts, or configs out of sync?
- was the request partially fulfilled but reported as complete?

### Step 5 — Decide the gate

Choose one clear verdict.

If the work should continue to QA, say exactly what QA must verify.
If it should go back to coding, say exactly what must be fixed first.

## Handoff rules

When sending work onward:
- to QA: include the highest-risk user flow and the most likely failure mode
- to docs: include what changed and what users/operators must now know
- back to coding: include the smallest fix list that would change the verdict

## Example triggers

- “帮我过一遍这个改动，看能不能进下一步”
- “别只看 diff，帮我做一次真正的 review gate”
- “这个功能到底算不算完成？”
- “先 review，再决定要不要做 browser QA”
