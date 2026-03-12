# StarChain References

## Status
- `current`
  - `pipeline-v2-5-contract.md`
  - `PIPELINE_FLOWCHART_V2_5_EMOJI.md`
  - `STARCHAIN_V2_5_SUMMARY.md`
- `previous`
  - `PIPELINE_FLOWCHART_V2_3_EMOJI.md`
- `supporting`
  - `arbitration-rubric.md`
  - `arbitration-trigger-conditions.md`
  - `l2-risk-classification.md`
  - `smoke-test-checklist.md`
  - `classification-model.md`
  - `cost-budget.md`
  - `epoch-confidence.md`
  - `exception-classification.md`
  - `incremental-review.md`
  - `monitor-alert-levels.md`
  - `performance-baseline.md`
  - `step-1.5-dependencies.md`
  - `task-cache.md`
  - `thinking-level-audit.md`

## Read Order
1. `pipeline-v2-5-contract.md`
2. `PIPELINE_FLOWCHART_V2_5_EMOJI.md`
3. `STARCHAIN_V2_5_SUMMARY.md`
4. `../SKILL.md`
5. Supporting documents as needed

## Notes
- `pipeline-v2-5-contract.md` 描述执行约束，`PIPELINE_FLOWCHART_V2_5_EMOJI.md` 描述主链与分支顺序。
- `../SKILL.md` 保留更完整的架构背景、workspace 拓扑，以及 `Spec-Kit` / `NotebookLM` 的既有定义。
- `Spec-Kit` 是 `v2.5` 默认主链的一部分，不是可选 companion。
- 某一份文档如果没展开配套层，不表示该层已从 `v2.5` 架构移除。
- Current `v2.5` flowchart includes TF recovery, L1 fast lane, retry, notification, degradation, and safety-net appendices.
- Keep only current files, one previous reference, and supporting materials.
- Older deprecated references have been removed to reduce prompt drift.
