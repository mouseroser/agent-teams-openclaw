---
name: autoplan-lite
description: Create a lightweight multi-agent planning pass for medium-complexity product, coding, research, or workflow tasks. Use when a request is too important for a single quick answer but too small for a full starchain/xingjian pipeline, especially for L2 tasks that need scope shaping, challenge/constitution review, engineering planning, risk review, and a final executable plan.
---

# Autoplan Lite

## Overview

Use this skill to turn a medium-complexity request into a compact, execution-ready plan without invoking a full heavyweight pipeline. The goal is to compress good product thinking, challenge, engineering planning, and risk review into one short multi-agent pass.

## When to run

Use `autoplan-lite` when the task has enough ambiguity or impact that a single-pass answer is risky, but a full starchain-style deep pipeline would be overkill.

Good fits:
- L2 feature work
- medium-complexity coding tasks
- workflow or automation design
- product scoping with engineering implications
- research-to-build tasks that need a practical plan
- requests where scope, tradeoffs, and risks matter more than immediate implementation

Do not use it for:
- tiny edits or obvious one-step fixes
- pure execution requests with no planning value
- high-stakes or highly ambiguous work that needs the full constitution/research pipeline
- tasks that are mostly external-operation execution rather than planning

## Output contract

Produce one concise plan with these sections:
- Goal
- Scope in / scope out
- Key assumptions
- Main risks
- Recommended execution path
- Ordered task list
- Open decisions for the human

The final output should be short enough to act on immediately. Do not dump raw agent outputs. Synthesize.

## Workflow

### Step 1 — Frame the task

First, restate the task in operational terms:
- what is being built, changed, or decided
- what success looks like
- what constraints are already known
- whether this feels like L1, L2, or L3

If the task is actually L1, skip this skill and answer directly.
If the task is actually L3, recommend escalating to a heavier pipeline.

### Step 2 — Run the four-pass lite review

For a true L2 task, gather four compact perspectives in this order:

1. **Scope scan**
   - Use a fast model/agent to clarify the real problem, likely scope edges, missing context, and possible overbuild.
   - Ask: what are we actually solving, what is the smallest useful version, and what should probably be excluded?

2. **Challenge / constitution pass**
   - Use a stronger reasoning pass to test assumptions, surface hidden risks, and challenge weak framing.
   - Ask: what could make this plan wrong, premature, or wasteful?

3. **Engineering plan**
   - Produce the practical implementation path.
   - Ask: what sequence would a good builder follow, what dependencies matter, and where are the likely breakpoints?

4. **Risk review**
   - Review the plan for correctness, regression risk, incompleteness, testing gaps, and rollout hazards.
   - Ask: what is most likely to break or be forgotten?

Keep each pass compact. The point is not exhaustive research. The point is better planning.

## Default OpenClaw mapping

Prefer this default mapping unless the current system state suggests a better substitution:
- Scope scan → `gemini`
- Challenge / constitution pass → `openai`
- Engineering plan → `claude`
- Risk review → `review`
- Final synthesis → `main`

If one agent is unavailable, substitute pragmatically and continue. Do not block the whole planning flow on one missing lane.

## Main-session orchestration rules

When running this in the main session:
- keep orchestration in `main`
- use short prompts with explicit deliverables
- serialize the four passes; do not parallelize unless there is a clear reason
- carry forward only distilled findings, not full transcripts
- after the four passes, synthesize one actionable plan in the main voice

## Prompting guidance for each pass

### Scope scan prompt shape

Ask for:
- real problem statement
- smallest viable scope
- likely scope creep traps
- missing context questions

### Challenge / constitution prompt shape

Ask for:
- flawed assumptions
- hidden tradeoffs
- likely failure modes
- objections from a skeptical reviewer

### Engineering plan prompt shape

Ask for:
- recommended implementation approach
- ordered steps
- file/system areas likely involved
- dependencies, tests, and validation path

### Risk review prompt shape

Ask for:
- correctness concerns
- regression risk
- completeness gaps
- rollout or QA requirements

## Synthesis rules

The final answer should not read like four stitched agent messages. Convert the passes into one plan.

Prioritize:
1. clarity
2. sequencing
3. risk visibility
4. explicit open questions

If the human can plausibly act without another planning round, the output is good enough.

## Escalation rules

Escalate out of `autoplan-lite` when:
- the task expands into multi-system architecture or deep uncertainty
- external research becomes the bottleneck
- there are major policy, safety, or production consequences
- the human clearly wants a full formal pipeline

In those cases, recommend starchain, xingjian, or a deeper custom plan.

## Example use cases

Example triggers:
- “先给我一个实现这个功能的靠谱方案，不要直接开干”
- “这个需求值不值得做，怎么收 scope 最合理？”
- “帮我规划一下这个中等复杂度改造，别上 full pipeline”
- “先做一个多 agent 的轻量计划，再决定要不要开发”

## Near-term evolution

Once the first version is stable, extend it carefully with:
- optional `founder-office-hours` prelude for product framing
- optional `qa-browser-check` recommendation for UI workflows
- tighter handoff format into coding/review execution lanes
