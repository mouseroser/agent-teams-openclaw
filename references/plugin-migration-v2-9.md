# StarChain v2.9 Plugin Migration Blueprint

## Goal

Promote the following long-term skills into official StarChain plugins:
- `founder-office-hours`
- `autoplan-lite`
- `review-gate`
- `qa-browser-check`
- `release-retro`

The target state is a cleaner StarChain package with:
- one core orchestration skill
- a `plugins/` directory for long-term enhancement modules
- explicit plugin ownership and trigger semantics
- temporary backward compatibility during transition

## Target Structure

```text
starchain/
├── SKILL.md
├── references/
│   ├── pipeline-v2-9-contract.md
│   ├── PIPELINE_FLOWCHART_V2_9_EMOJI.md
│   ├── plugin-migration-v2-9.md
│   └── ...
└── plugins/
    ├── founder-office-hours/
    │   └── SKILL.md
    ├── autoplan-lite/
    │   └── SKILL.md
    ├── review-gate/
    │   └── SKILL.md
    ├── qa-browser-check/
    │   └── SKILL.md
    └── release-retro/
        └── SKILL.md
```

## Plugin Classification

### Core plugins
These should be treated as core StarChain plugins:
- `founder-office-hours`
- `autoplan-lite`
- `review-gate`

### Conditional plugins
These should be treated as route-dependent plugins:
- `qa-browser-check`
- `release-retro`

## Intended Runtime Semantics

### `founder-office-hours`
- plugin type: pre-planning / product-framing
- default use: L3, selected L2
- role: sharpen problem framing before deep planning or build

### `autoplan-lite`
- plugin type: lite-planning core
- default use: L2 default planning route
- role: produce a compact execution-ready plan and decide whether Lite can converge or should escalate to Full

### `review-gate`
- plugin type: quality gate
- default use: after coding in Lite and Full
- role: decide go / no-go for QA or next step

### `qa-browser-check`
- plugin type: browser QA gate
- default use: UI / workflow / browser-visible tasks only
- role: validate main browser path after review-gate

### `release-retro`
- plugin type: post-delivery retro
- default use: meaningful L2/L3 deliveries with learning value
- role: capture reusable improvements and patterns

## Migration Policy

### Phase 1 — Documentation-first migration
Before moving files:
- declare these modules as official StarChain plugins in `starchain/SKILL.md`
- add plugin references to the v2.9 contract
- document migration target and compatibility policy

Status: in progress

### Phase 2 — Physical directory migration
Move the five skill directories into `starchain/plugins/`.

Required actions:
1. create `starchain/plugins/`
2. move each plugin directory under it
3. verify each plugin `SKILL.md` still stands alone and reads correctly
4. update any references that assume top-level placement

### Phase 3 — Compatibility layer
Keep temporary compatibility during transition.

Recommended compatibility policy:
- short term: keep top-level copies or stubs only if needed for discovery
- medium term: remove top-level duplicates after StarChain docs and usage stabilize

Preferred end state:
- only StarChain-owned plugin directories remain
- the core StarChain skill documents when each plugin should be invoked

## Reference Updates Required

Update these references after the physical move:
- `starchain/SKILL.md`
- `references/pipeline-v2-9-contract.md`
- `references/PIPELINE_FLOWCHART_V2_9_EMOJI.md` (if path references are added later)
- any future notes that name the plugins as standalone long-term skills
- plugin-suite language should describe all five modules, with `autoplan-lite` as the Lite core plugin

## Naming Policy

Prefer keeping the plugin folder names unchanged for now:
- `founder-office-hours`
- `review-gate`
- `qa-browser-check`
- `release-retro`

Reason:
- avoids unnecessary semantic churn
- keeps existing tested wording intact
- reduces migration risk

If a later rename is desired, do it as a separate cleanup step.

## Backward Compatibility Options

### Option A — Hard move now
- move directories under `starchain/plugins/`
- remove top-level copies immediately
- update StarChain docs in the same change

Pros:
- cleanest end state immediately

Cons:
- highest short-term breakage risk if anything still assumes top-level placement

### Option B — Move + temporary duplicate compatibility
- move canonical plugin directories under `starchain/plugins/`
- keep top-level copies briefly if needed
- remove top-level copies after validation

Pros:
- safer migration

Cons:
- temporary duplication risk

### Recommendation
Use **Option B** if immediate compatibility uncertainty exists.
Use **Option A** only if reference and trigger behavior are fully understood before the move.

## Validation Checklist

After migration, validate:
- StarChain core skill still reads cleanly
- each plugin skill still validates individually
- package validation still succeeds for StarChain
- plugin ownership is explicit in docs
- no stale top-level references remain
- no duplicate long-term source of truth remains after cleanup

## Risks

### Risk 1 — stale references
Some docs may continue to describe the plugins as standalone long-term skills.

Mitigation:
- grep references after move
- update ownership language in StarChain docs first

### Risk 2 — duplicate source of truth
Keeping both top-level and plugin-local copies too long can create divergence.

Mitigation:
- pick one canonical location quickly
- set a cleanup deadline

### Risk 3 — over-coupling too early
If plugin logic changes rapidly, deep structural nesting can slow iteration.

Mitigation:
- keep plugin content self-contained
- keep names stable
- avoid premature internal API contracts

## Recommended Execution Order

1. finish documentation-first migration
2. grep all references to the four plugin names and current top-level paths
3. choose Option A or B based on actual reference spread
4. perform physical move
5. validate packages and references
6. remove temporary compatibility layer when stable

## Immediate Next Step

Run a reference scan to determine whether the four plugin skills can be hard-moved immediately or whether a temporary compatibility phase is required.
