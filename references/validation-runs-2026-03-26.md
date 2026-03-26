# StarChain v2.9 Validation Runs — 2026-03-26

## Purpose

Record the first real validation runs for the StarChain v2.9 plugin suite.

This file is intentionally about **real usage**, not hypothetical examples.

---

## Run 1 — Track A: L2 feature planning

### Task
助贷 CRM 系统规划

### Route
StarChain Lite

### Plugins used
- founder-office-hours
- autoplan-lite

### Why this route
This was a real L2 planning task:
- too large for a trivial one-shot answer
- not yet heavy enough to require Full Starchain
- needed product framing before implementation planning

### What changed materially
#### founder-office-hours
Reframed the problem from “build a generic CRM” into a much tighter wedge:
- 助贷线索流转
- 跟进推进
- 转化可视

This reduced unnecessary platform scope early.

#### autoplan-lite
Converted the reframed task into directly usable build artifacts:
- goals
- scope in / out
- staged milestones
- data model
- page structure
- API draft
- coding prompt

### Verdict
Pass

### Key finding
`founder-office-hours + autoplan-lite` is a valid and valuable Lite route for medium-complexity product/system planning.

### Scores
- route selection quality: 5/5
- output usefulness: 5/5
- reduction of unnecessary work: 5/5
- handoff clarity: 5/5

---

## Run 2 — Track B: browser-visible workflow quality

### Task
小红书标签故障 / 发布链路修复

### Plugins validated
- review-gate
- qa-browser-check

### Why this task qualifies
This was not just a code bug. It was a browser-visible workflow failure:
- publishing appeared to succeed
- but `#标签` was emitted into body text
- the platform topic selector was not actually driven correctly

### review-gate verdict
**Needs fixes before QA**

Reason:
- execution success was not equal to business correctness
- the workflow failed at the correctness/completeness layer
- “能发出去” was not enough; the output shape on platform was wrong

### qa-browser-check verdict
**Fail on real workflow**

Observed failure:
- tags were posted as body text
- expected topic selection behavior did not happen in the real platform flow

### Key finding
`review-gate` is useful for catching “looks done but is not actually correct”.
`qa-browser-check` is useful for platform-visible workflow validation that code review alone can miss.

### Scores
- review-gate usefulness: 5/5
- qa-browser-check usefulness: 5/5
- correctness improvement: 5/5

---

## Run 3 — Track C: incident / root-cause investigation

### Task
本地 rerank sidecar 健康异常

### Plugins used
- investigate-root-cause
- guard-mode

### Guard profile used
Task-local bounded investigation:
- observe first
- do not broad-rebuild the system blindly
- do not mutate unrelated config
- only inspect service health, launchd state, logs, and runtime environment

### What happened
Symptom:
- `http://127.0.0.1:8765/health` had no response
- launchctl job existed
- service was not actually serving

### Confirmed root cause
The local sidecar virtual environment was broken.

Exact mechanism:
- `.venv/bin/python3` crashed on startup
- missing dynamic library: `libpython3.12.dylib`
- launchd repeatedly failed to start the service

### Fix executed
- removed broken `.venv`
- reran `uv sync`
- restarted `com.openclaw.local-rerank-sidecar`
- revalidated `/health`

### Result
Pass

Service recovered successfully:
- model loaded
- `/health` returned `200`

### Key finding
`investigate-root-cause` is validated by real diagnosis and not just analysis theater.
`guard-mode` is validated as a useful overlay that prevented premature broad repair.

### Scores
- investigate-root-cause usefulness: 5/5
- guard-mode usefulness: 4.5/5
- reduction of blind edits: 5/5
- stability improvement: 5/5

---

## Run 4 — Track D: release-retro

### Subject
2026-03-26 gstack → StarChain v2.9 adaptation and pluginization cycle

### Plugin used
- release-retro

### Scope of retro
This retro covered the full cycle:
- gstack adaptation judgment
- first-wave plugin selection and validation
- StarChain v2.9 structure update
- hard move into `starchain/plugins/`
- second-wave plugin addition
- validation plan and plugin API docs
- repo cleanup and push
- rerank sidecar diagnosis/fix as part of operational learning

### What worked
- translate methodology first, integrate second
- validate Lite before hard-wiring it into the suite
- hard-move to official plugin suite once canonical list is confirmed
- keep plugin API lightweight and documentation-level first

### What hurt
- one temporary mismatch between 4-skill and 5-skill framing
- `.DS_Store` artifacts slipped into an early push
- progress wording was occasionally ahead of landed state

### What should persist
- route changes must trigger canonical set re-evaluation
- migration push should include dirty-file cleanup
- status reporting should distinguish: landed / validated / committed / pushed

### Verdict
Pass

### Key finding
`release-retro` is valuable after non-trivial delivery cycles, especially where architecture, workflow, and execution discipline all changed at once.

### Score
- retention value: 4.5/5
- operational usefulness: 4.5/5

---

## Consolidated suite status after first validation day

### Strongly validated
- founder-office-hours
- autoplan-lite
- review-gate
- qa-browser-check
- release-retro
- investigate-root-cause
- guard-mode

### Dedicated validation added
- design-review-lite

### Run 5 — Supplemental validation: design / IA sanity review

#### Task
助贷 CRM 系统的页面结构 / 信息组织 / 操作流梳理

#### Plugin used
- design-review-lite

#### Why this qualifies
Although the broader CRM task started as Lite planning, one real sub-problem inside it was explicitly product/design-shaped rather than implementation-shaped:
- 页面怎么分
- 线索列表、详情、跟进、转化看板如何组织
- 哪些信息必须在第一屏
- 哪些能力不该在 v1 暴露过多

This is a genuine UI / IA / operator-flow design problem.

#### What design-review-lite changed materially
It changed the discussion from “what features should exist” into “how the operator will actually move through the system”.

Useful review outputs included:
- defining the core operator task first
- separating primary workflow screens from secondary admin/config screens
- identifying where too many CRM-like options would overload v1
- making sure list → detail → follow-up → conversion progression stays short and legible
- preferring fewer surfaces with clearer state transitions over a bloated general dashboard

#### Design verdict
**Build but simplify first**

Reason:
- the system direction was good
- but the useful first version needed tighter screen hierarchy and less option sprawl
- operator clarity mattered more than feature breadth

#### Key finding
`design-review-lite` is useful as a pre-build shaping layer when the task has already been product-framed, but the interface structure still risks becoming too broad or too CRM-generic.

#### Scores
- clarity improvement: 4.5/5
- reduction of UX/IA sprawl: 4.5/5
- usefulness before implementation: 4.5/5

---

## Overall conclusion

StarChain v2.9 pluginization is no longer only a documentation exercise.

After the first real validation day:
- the Lite path is validated
- the quality gate path is validated
- the incident/root-cause path is validated
- the retro path is validated

The suite has moved from concept → production-shaped orchestration primitives.
