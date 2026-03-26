# StarChain v2.9 Contract

## Status
- Current formal version: **v2.9**
- Previous formal version: **v2.8**
- Execution mode: **main orchestrates directly in the main session**

## Purpose

StarChain v2.9 keeps the v2.8 Full pipeline intact while adding:
- a **Lite route** for L2 tasks
- a **product framing layer** before deeper planning
- a stronger **review gate**
- optional **browser QA** for UI/workflow tasks
- an optional **release retro** after delivery

The goal is not to make every task heavier. The goal is to match task weight to the right route.

## Official Plugin Layer

The following long-term modules are treated as official StarChain plugins:
- `founder-office-hours`
- `autoplan-lite`
- `review-gate`
- `qa-browser-check`
- `release-retro`

Canonical ownership: these modules now live under `starchain/plugins/` as the official StarChain plugin suite.

## Route Selection Contract

### L1
- Do not enter StarChain.
- main handles directly or delegates to a single agent when enough.

### L2
- Default route: **StarChain Lite**
- Upgrade to Full if the task expands into architecture, security, data migration, deep research, or unresolved planning conflict.

### L3
- Default route: **StarChain Full**
- `founder-office-hours` enabled by default before deeper planning.

## Lite Route Contract

### Entry conditions
Use Lite when:
- the task is L2
- planning value is high but full research cost would be excessive
- scope needs shaping
- the user wants a strong plan before implementation

### Lite route order
1. `main` — classify L1/L2/L3 and choose Lite
2. `founder-office-hours` — optional; use when the direction or wedge is unclear
3. `autoplan-lite` — required for L2 default route
4. `coding` — implementation
5. `review-gate` — mandatory gate after coding
6. `test` and/or `qa-browser-check` — based on task type
7. `docs` — when docs or delivery notes are needed
8. `main` — final synthesis and delivery
9. `release-retro` — optional when the run produced reusable learnings or repeated failures

## Full Route Contract

### Entry conditions
Use Full when:
- the task is L3
- the task crosses modules or systems
- the task involves security, permissions, data migration, or high operational risk
- deep research/history retrieval is likely to change the implementation path
- Lite route cannot converge

### Full route order
1. `main` — classify L1/L2/L3 and choose Full
2. `founder-office-hours` — default for L3
3. `gemini` — scan ambiguity / risk / boundaries
4. `notebooklm` — retrieve history, templates, recurring pitfalls
5. `openai` — constitution / constraints only
6. `claude` — primary implementation plan
7. `gemini` — consistency review
8. `openai` / `claude` — arbitration if needed
9. `brainstorming` — Spec-Kit (`spec.md`, `plan.md`, `research.md`, `tasks.md`, analyze)
10. `coding` — implementation
11. `review-gate` — mandatory gate after coding
12. `test` and/or `qa-browser-check` — based on task type
13. `docs` — docs and delivery notes
14. `main` — final synthesis and delivery
15. `release-retro` — optional after delivery when worthwhile

## Product Framing Layer Contract

### `founder-office-hours`
Use when the request is still partially a product decision.

Expected output:
- core problem
- who benefits
- why now
- smallest useful wedge
- scope to cut
- key tradeoffs
- recommendation: build / shrink / defer / reject

This layer should reduce overbuild before planning deepens.

## Planning Layer Contract

### `autoplan-lite`
Use for L2 default planning.

Expected output:
- goal
- scope in / out
- assumptions
- main risks
- recommended execution path
- ordered task list
- open decisions

If `autoplan-lite` cannot stabilize the plan, upgrade the task to Full.

## Quality Gate Contract

### `review-gate`
Mandatory after coding in both Lite and Full.

Required output:
- verdict
- correctness concerns
- regression risks
- completeness gaps
- required validations
- recommended next step

Allowed verdicts:
- Pass
- Pass with follow-ups
- Needs fixes before QA
- Blocked

Coding announce is never sufficient proof of completion.

## QA Contract

### `test`
Use for code/logic validation.

### `qa-browser-check`
Use for UI, workflow, dashboard, settings, login-dependent, or browser-visible tasks.

If both are needed:
- run `test` first
- then run `qa-browser-check`

## Retro Contract

### `release-retro`
Run only when the cycle produced value worth preserving.

Trigger examples:
- L2/L3 delivery with meaningful complexity
- repeated failures
- new checklist or skill candidates
- painful but educational run

Expected output:
- what happened
- what worked
- what hurt
- repeated patterns
- what to record or promote
- immediate follow-ups

## Hard Rules

- Never orchestrate StarChain via isolated `main` session nesting.
- Never let review agents orchestrate other agents.
- Never treat agent self-push as the reliable notification chain.
- Never skip the quality gate after coding.
- Never force every task through every new skill; route selectively.
- Never send L1 work into StarChain just to preserve process shape.

## Notification Contract

- main sends reliable start/progress/completion notifications
- Step 7 final delivery remains on main
- monitor group + 晨星 DM remain the reliable chain

## Retry Contract

For spawned agents:
1. immediate retry once
2. retry again after 10 seconds
3. on third failure, mark BLOCKED and notify
