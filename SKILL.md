---
name: starchain
description: 星链（StarChain）— OpenClaw 多 agent 协作锻造流水线 v2.2。从 Step 1 分级到 Step 7 交付的全自动编排，优化 Constitution-First Step 1.5 + 增强 Gemini 快速复核与预审机制 + 强化 Step 5.5 Epoch 诊断与仲裁，提升效率 30-40%，降本 25-35%，Epoch 成功率提升 15-20%。
---

# 星链 StarChain

星链是 OpenClaw 的多 agent 协作流水线，以 main（小光）为编排中心，链式串联所有 agent 完成从需求到交付的全流程。

使用本 skill 执行开发和修复任务，遵循 `references/pipeline-v1-9-contract.md` 中的流水线合约。

## When This Skill Triggers

Trigger this skill when the user asks to:
- run the cross-review pipeline
- assign work across review/coding/test/docs/monitor/brainstorming
- enforce Step 1.5 spec-kit gates
- handle Step 3/4/5 verdict loops and Epoch fallback
- create specs/plans/tasks for a feature (spec-kit workflow)

## Required Read

Before execution, read:
1. `references/PIPELINE_FLOWCHART_V2_1_EMOJI.md` — 默认流程图（完整的可视化流程）
2. `references/pipeline-v2-1-contract.md` — 流水线合约（详细规则）

## Versioning Policy

- **小更新不升版本号**：措辞优化、通知规则细化、轻量步骤调整、同一框架内的补丁修正，直接在当前版本内迭代。
- **大变动才生成新版本**：当流程主干、阶段职责、核心门控、模型分工、回滚逻辑或交付结构发生实质变化时，才创建新的 `vX.Y`。
- **只保留最近两个版本**：当前版本 + 上一个版本。更老版本应归档或删除，避免执行时误读。
- **默认入口始终指向最新版本**；上一个版本仅作为回看与回滚参考。

### Version Retention SOP

当生成新版本时，按以下顺序执行：
1. 先创建新的 flowchart 与 contract 文件（如 `v1.10`）。
2. 将 `SKILL.md` 默认入口切到最新版本。
3. 将上一版本保留为唯一回看/回滚版本。
4. 对更老版本：
   - 若仍需留痕，标记为 deprecated 并移出默认入口。
   - 若已无保留价值，直接归档或删除。
5. 任何时刻，references/ 中默认活跃版本最多只应有两套：`current` + `previous`。
6. 若发现超过两个版本同时处于可执行状态，必须立即清理，避免执行时读错版本。

## Architecture: main 编排模式

main（小光）是顶层编排中心。所有 agent 由 main 直接 spawn（mode=run），main 在持久会话中串联全流程。

```
main（小光，读取本 SKILL.md 后充当编排中心）
├── Step 1：main 自己做分级 + 类型分析
├── Step 1.5：gemini 颗粒度对齐 → claude（小克）出计划 → review/gemini 复核 → review/gpt（L3/高风险时仲裁）
├── Step 2：spawn coding（含 Step 2.5 冒烟）
├── Step 3：spawn review（只做交叉审查）
│   └── main 直接 grep 验证修复（不信 coding announce）
├── Step 4：spawn brainstorming → spawn coding → spawn review（循环，max 3 rounds）
├── Step 5：spawn test
├── Step 5.5：spawn brainstorming → spawn coding → spawn test（Epoch 循环，max 3）
├── Step 6：spawn 珊瑚(notebooklm) → spawn 织梦(gemini) → spawn docs
├── Step 7：main 汇总交付 + message 通知晨星
└── 全程：main 补发关键推送到各职能群 + 监控群（sub-agent 推送不可靠）
```

### Workspace 架构

**Main Agent 工作目录**：
- `~/.openclaw/workspace/` - Main agent (小光) 的工作目录
- `workspace/intel/` - Agent 协作文件（单写者原则）
  - `1-MONITOR-TRENDS.md` - monitor-bot 写入
  - `2-BRAINSTORM-IDEAS.md` - brainstorming 写入
- `workspace/shared-context/` - 跨 agent 共享上下文
  - THESIS.md, FEEDBACK-LOG.md, SIGNALS.md
- `workspace/memory/` - 记忆文件
- `workspace/*.json` - 历史记录

**Sub-Agent 工作目录**：
- `~/.openclaw/workspace/agents/brainstorming/` - Spec-Kit 产物
  - `specs/` - 规格文档
- `~/.openclaw/workspace/agents/gemini/` - 分析报告
  - `reports/` - 研究报告
- `~/.openclaw/workspace/agents/claude/` - 计划报告
  - `reports/` - 实施计划
- `~/.openclaw/workspace/agents/coding/` - 代码产物
- `~/.openclaw/workspace/agents/review/` - 审查产物
- `~/.openclaw/workspace/agents/test/` - 测试产物
- `~/.openclaw/workspace/agents/docs/` - 文档产物
- `~/.openclaw/workspace/agents/notebooklm/` - NotebookLM 产物
- `~/.openclaw/workspace/agents/{agent}/` - 各 agent 的工作产物

**文件传递规则**：
- 每个 agent 在自己的 workspace 目录中生成工作产物
- 通过 `~/.openclaw/workspace/intel/` 目录传递摘要或索引（单写者原则）
- Main agent 或其他 agent 直接读取对应 agent 的 workspace 目录获取完整产物

### 知识层集成（珊瑚 NotebookLM）
- Step 1.5：spawn 珊瑚查询 openclaw-docs / memory notebook 获取相关上下文
- Step 6：spawn 珊瑚查询 notebook 辅助文档生成
- 珊瑚通过 nlm-gateway.sh 访问 notebooks（按 ACL 权限）
- Notebook：memory / openclaw-docs / media-research

## Agent Roles

| Agent | Role | Key Steps |
|-------|------|-----------|
| main（小光） | 顶层编排中心 | Step 1, 1.5 编排, 4 编排, 5.5 编排, 7 |
| gemini（织梦） | 颗粒度对齐 + 复核 | Step 1.5(问题宪法), Step 1.5(复核), Step 6(润色), Step 5.5(诊断) |
| claude（小克） | 实施计划 | Step 1.5(基于宪法出计划) |
| review | 交叉审查 + 复核 + 仲裁 | Step 1.5(swap gemini 复核), Step 1.5(swap gpt 仲裁), Step 3(交叉审查) |
| coding | 开发执行 | Step 2, 2.5, 4(fix), TF(fix) |
| test | 测试执行 | Step 5, TF(rerun), Epoch(test) |
| brainstorming | 方案智囊 | Step 1.5(spec-kit), 4(方案), TF-2/3(方案), 5.5(分析) |
| docs | 文档生成 | Step 6 |
| 珊瑚(notebooklm) | 知识查询 | Step 1.5(历史知识), Step 6(文档模板) |
| monitor-bot | 全局监控 | 全程状态 + 告警 |

## Spawn 规范

所有 agent 一律用 `mode=run` spawn：

```
sessions_spawn(agentId: "<agent>", mode: "run", task: "<任务+上下文>")
```

- main 是持久会话，每个 agent announce 回来后 main 继续下一步
- 不需要 mode=session，不需要 thread
- runTimeoutSeconds 按需设置（coding/brainstorming 建议 300s，其他默认）

### Spawn 重试机制（硬性要求）

任何 agent spawn 失败时（包括 LLM request timed out、503、网络错误等），main 必须自动重试：

1. 第一次失败 → 立即重试（相同参数）
2. 第二次失败 → 等待 10 秒后重试
3. 第三次仍失败 → 推送告警到监控群(-5131273722) + 通知晨星(target:1099011886)，标记该步骤为 BLOCKED

**绝不因为单次 spawn 失败就跳过步骤或 HALT。** 瞬时超时和 API 抖动是常见现象，重试通常能解决。

```
# 重试伪代码
for attempt in 1, 2, 3:
    result = sessions_spawn(...)
    if result.ok: break
    if attempt == 2: sleep(10)
    if attempt == 3: alert + BLOCKED
```

## Spec-Kit Integration (Step 1.5)

L2/L3 tasks must pass the Spec-Kit gate before Step 2. The workflow:
1. `specify` → specs/{feature}/spec.md (WHAT/WHY, no HOW)
2. `plan` → specs/{feature}/plan.md + research.md (tech decisions with rationale)
3. `tasks` → specs/{feature}/tasks.md (ordered, dependencies marked, [P] for parallel)
4. `analyze` → consistency check (spec ↔ plan ↔ tasks)

Critical consistency issues block Step 2. Brainstorming agent executes; main orchestrates.

### Optional Gemini Accelerator (Default: enabled for L2/L3)
- Step 1.5: main spawns gemini to generate clarification questions + risks + research bullets; feed into brainstorming context and fold into research.md.
- Step 6: before spawning docs, main spawns gemini to draft release-notes/FAQ outline; include as docs input.
- Step 5.5: when entering Epoch/HALT, main spawns gemini to summarize failure logs into a diagnosis memo for monitor-bot + delivery notes.

Reference: https://github.com/github/spec-kit

## Main 编排流程（逐步执行）

### Step 1：分级 + 类型分析
main 自己执行：
1. 判断等级：L1 / L2 / L3
   - L1：简单修复、配置调整、文档更新
   - L2：标准功能开发、中等复杂度重构
   - L3：大型功能、架构重构、跨模块变更
2. 判断类型：A / B / C → 确定各 agent 模型配置
3. 推送分配单到监控群(-5131273722)
4. L1 → 快速通道 | L2/L3 → Step 1.5

**成本优化策略（质量优先）**：
- L1：跳过 brainstorming（已实现）
- L2/L3：保持 sonnet/opus 模型不变
- **通过 Thinking Level 优化成本**：
  - Step 1.5: thinking="medium" (深度思考)
  - Step 4 R1: thinking="low" (快速方案)
  - Step 4 R2: thinking="medium" (更多思考)
  - Step 4 R3: thinking="high" + opus (深度分析)
  - 预期降本 10-15%

### Step 1.5：Constitution-First 打磨层（L2/L3）
main 编排：

**L2 标准链：**

1️⃣ **spawn gemini（织梦）/think medium**
   - 颗粒度对齐 / 问题定义同步
   - 产出「问题宪法」
   - 输出路径：`agents/gemini/reports/*-constitution-*.md`
   - 通知：织梦群 (-5264626153) + 监控群

2️⃣ **spawn claude（小克）/think medium**
   - 基于「问题宪法」产出实施计划
   - 结构：目标 / 边界 / 风险 / 执行步骤 / 依赖
   - 输出路径：`agents/claude/reports/*-plan-*.md`
   - 通知：小克群 (-5101947063) + 监控群

3️⃣ **spawn review（swap 到 gemini）/think medium**
   - 复核 claude 计划是否偏离原问题宪法
   - 命令：`sessions_spawn(agentId: "review", model: "gemini/gemini-3.1-pro-preview", thinking: "medium", ...)`
   - 输出：ALIGN / DRIFT / MAJOR_DRIFT
   - 通知：交叉审核群 (-5242448266) + 监控群

   **判定：**
   - ALIGN ✅       → Step 2
   - DRIFT ⚠️       → claude 修订 1 次 → review/gemini 再复核
   - MAJOR_DRIFT ❌ → 升级到 Step 1.5.4

**L3 升级链（或 MAJOR_DRIFT）：**

4️⃣ **spawn review（swap 到 gpt）/think high**
   - 风险挑刺 / 反方审查 / 仲裁
   - 命令：`sessions_spawn(agentId: "review", model: "openai/gpt-5.4", thinking: "high", ...)`
   - 输出：GO / REVISE / BLOCK
   - 通知：交叉审核群 (-5242448266) + 监控群

   **判定：**
   - GO ✅      → Step 2
   - REVISE ⚠️  → claude 修订 1 次 → review/gemini 复核 → 再判定
   - BLOCK ❌   → main 推送阻塞原因 → HALT / 降级交付

**规则：**
- 🚫 不新增晨星中途确认节点，全自动推进
- 🚫 这条前置链不替换后续开发 / 审查 / 测试主干
- ✅ 一致性复核是 review 的职责，通过 swap 模型实现
- ✅ gemini 只负责问题宪法（Step 1.5.1），不直接做复核

> **打磨层理念**：gemini 提炼问题宪法 → claude 基于宪法出计划 → review/gemini 复核一致性 → review/gpt 高风险仲裁。

### Step 2 + 2.5：开发 + 冒烟
main 编排：
1. spawn coding → 按 tasks.md 开发 + 自执行冒烟测试
2. coding announce 回来后，main 检查结果
3. **冒烟测试结果处理（优化：失败分类）**：
   - **PASS** → 创建 S1 快照，进入 Step 3
   - **FAIL** → coding 分析失败类型：
     - **语法/编译错误**：coding 自修复（max 2 次）
       - 修复成功 → 创建 S1 快照，进入 Step 3
       - 2 次仍失败 → 进入 Step 4（带详细错误日志）
     - **逻辑/功能错误**：直接进入 Step 4（带详细测试日志）
   
**优化收益**：减少 20% 的 Step 4 进入次数，简单语法错误快速自修复

### Step 3：交叉审查 + Gemini 快速复核
main 编排：

**Type A（业务/架构）：**
1. spawn review（swap gpt）→ 结构化交叉审查
2. spawn review（swap gemini）→ 快速复核代码是否符合需求
3. 综合判定：
   - 两者都 PASS → 创建 S2 快照，进入 Step 5
   - 任一 NEEDS_FIX → 进入 Step 4

**Type B（算法/性能）：**
1. spawn review（swap gemini）→ 算法分析 + 性能审查
2. 判定：
   - PASS → 创建 S2 快照，进入 Step 5
   - PASS_WITH_NOTES → minor fix diff ≤ G2 免审 → S2 → Step 5；diff > G2 降级 NEEDS_FIX
   - NEEDS_FIX → 进入 Step 4

**优化收益**：
- Type A: gemini 快速复核可提前发现 30-40% 的需求偏离问题
- Type B: gemini 擅长算法分析，比 sonnet 更适合

**Spawn 示例：**
```javascript
// Type A: review swap gpt
sessions_spawn(
  agentId: "review",
  model: "openai/gpt-5.4",
  thinking: "high",
  task: "结构化交叉审查..."
)

// Type A/B: review swap gemini（快速复核/算法分析）
sessions_spawn(
  agentId: "review",
  model: "gemini/gemini-3.1-pro-preview",
  thinking: "medium",
  task: "快速复核代码是否符合需求..."
)
```

### Step 4：修复循环 + Gemini 预审（max 3 rounds）
main 编排每轮：

1. 组装 context bundle（需求 + diff + issues JSON + 前轮反馈）
2. spawn brainstorming → 出修复方案
3. spawn coding → 执行修复
4. **spawn review（swap gemini）→ 快速预审**
   - 发现明显问题（语法错误、逻辑漏洞、需求偏离）
   - 预审 PASS → 进入 Step 4.5（正式审查）
   - 预审 FAIL → 直接进入下一轮修复（节省成本）
5. **Step 4.5：正式审查**
   - 回到 Step 3（spawn review 根据 Type A/B 正式审查）

**模型与 Thinking Level 配置（质量优先 + 成本优化）**：
- R1: brainstorming sonnet/low + coding gpt/medium + review/gemini 预审
- R2: brainstorming sonnet/medium + coding gpt/medium + review/gemini 预审
- R3: brainstorming opus/high + coding gpt/xhigh + review/gemini 预审
- R3 仍 NEEDS_FIX → Step 5.5

**优化收益**：
- gemini 预审可提前发现 30-40% 的明显问题
- 避免浪费 gpt/sonnet 的高成本审查
- 预计降本 15-20%

**Spawn 示例：**
```javascript
// Step 4.4: gemini 预审
sessions_spawn(
  agentId: "review",
  model: "gemini/gemini-3.1-pro-preview",
  thinking: "low",
  task: "快速预审修复代码，发现明显问题..."
)
```

### Step 5：全量测试
main 编排：
1. spawn test → 执行完整测试
2. PASS → 创建 S3 快照，进入 Step 6
3. FAIL → 进入 TF 路径

### TF（Test Failure）路径
main 编排：
- TF-1: spawn coding 修复 → spawn test 重跑
- TF-2: spawn brainstorming(sonnet/medium) → spawn coding → spawn test
- TF-3: spawn brainstorming(opus/high) → spawn coding → spawn test + 全量回归
- diff > G3 → 回 Step 3（ReEntry++）
- ReEntry > 2 → 强制 Step 5.5

### Step 5.5：Epoch 回退 + 增强诊断（max 3 Epochs）
main 编排：

1. **spawn gemini（织梦）/think high** → 产出诊断 memo
   - 快速分析失败模式
   - 识别根本原因
   - 输出路径：`agents/gemini/reports/*-diagnosis-*.md`

2. **spawn review（swap gemini）/think medium** → 复核诊断
   - 检查诊断是否遗漏关键信息
   - 补充遗漏的失败模式
   - 输出：COMPLETE / INCOMPLETE

3. **spawn brainstorming（opus）/think high** → 根因分析 + 回滚决策
   - 输入：诊断 memo + 复核结果 + 历史决策数据（epoch-history.json）
   - 分析根本原因
   - 决定回滚策略：S1 / S2 / 继续
   - 输出：回滚决策 + 理由

4. **spawn review（swap gpt）/think high** → 仲裁回滚决策（高风险场景）
   - 仅在以下情况触发：
     - Epoch >= 2（第二次及以上回退）
     - 决策为回滚到 S1（影响较大）
     - brainstorming 信心度 < 0.7
   - 输出：APPROVE / REJECT / REVISE

5. **执行回滚**
   - 回滚代码到选定快照
   - 重新走 Step 2 → 2.5 → 3 → 5

6. **记录 Epoch 结果**
   - 更新 workspace/epoch-history.json
   - 记录：决策、快照、结果、耗时、诊断摘要

7. **Epoch > 3 → HALT**

**epoch-history.json 格式**：
```json
{
  "epochs": [
    {
      "timestamp": 1772691000000,
      "decision": "rollback_to_S1",
      "reason": "架构变更过大",
      "diagnosis_summary": "gemini 诊断发现架构冲突",
      "result": "success",
      "duration_ms": 180000
    }
  ]
}
```

**优化收益**：
- review/gemini 复核诊断，避免遗漏关键信息
- review/gpt 仲裁回滚决策，避免错误回滚
- Epoch 成功率提升 15-20%（原 10-15%）

**Spawn 示例：**
```javascript
// Step 5.5.1: gemini 诊断
sessions_spawn(
  agentId: "gemini",
  thinking: "high",
  task: "分析测试失败日志，产出诊断 memo..."
)

// Step 5.5.2: review/gemini 复核诊断
sessions_spawn(
  agentId: "review",
  model: "gemini/gemini-3.1-pro-preview",
  thinking: "medium",
  task: "复核诊断 memo，检查是否遗漏关键信息..."
)

// Step 5.5.3: brainstorming 根因分析
sessions_spawn(
  agentId: "brainstorming",
  model: "anthropic/claude-opus-4-6",
  thinking: "high",
  task: "基于诊断 memo 和复核结果，分析根因并决定回滚策略..."
)

// Step 5.5.4: review/gpt 仲裁（按需）
sessions_spawn(
  agentId: "review",
  model: "openai/gpt-5.4",
  thinking: "high",
  task: "仲裁回滚决策，评估风险..."
)
```

### Step 6：文档（L1 跳过）
main 编排：
1. **珊瑚知识查询**（可选）：
   - spawn notebooklm (珊瑚) → 查询 openclaw-docs notebook
   - 任务：`查询关于 <功能名称> 的文档模板和示例`
   - 珊瑚返回文档模板和最佳实践
   - 如果失败 → Spawn 重试 → Warning → 降级跳过
2. **织梦加速**：spawn 织梦(gemini, thinking="medium") → 产出交付说明/FAQ 大纲
   - 输入：最终 diff + 需求 + 珊瑚文档模板（如有）
3. **docs 生成**：spawn docs → 生成/更新文档
   - 输入：织梦大纲 + 代码 diff + 审查摘要
4. 由 main 推送文档群(-5095976145) + 监控群

### Step 7：交付
main 自己执行：
1. 汇总交付摘要（scope + files + test + review + level + status + snapshots）
2. 推送监控群(-5131273722)
3. 通知晨星(target:1099011886)

## Execution Rules

0. **全自动推进，不停顿。** 除 Step 7 晨星确认外，所有步骤自动衔接，绝不暂停等待用户确认。进度推送到监控群即可，不要问"要继续吗"。
1. Always start at Step 1 (L1/L2/L3 classification + track selection).
2. L1 goes to fast lane; L2/L3 must pass Step 1.5 before Step 2.
3. main is orchestration center; all agents are direct executors.
4. Use structured verdict flow (`PASS`, `PASS_WITH_NOTES`, `NEEDS_FIX`) exactly as defined.
5. Apply weighted diff gates exactly:
   - G2 = 20 weighted lines
   - G3 = 30 weighted lines
6. Enforce bounded loops:
   - `ReEntry_MAX = 2`
   - Step 4 max 3 rounds
   - Step 5.5 max 3 Epochs
7. Use snapshots and timeout fallback exactly:
   - S1 after Step 2
   - S2 after Step 3 PASS
   - S3 after Step 5 PASS
   - only halt point: Epoch > 3
   - halt timeout fallback: 30min degraded delivery from S2
8. Step 7 delivery must include level, delivery status, and snapshot tags.
9. Step 1.5 spec-kit artifacts must be complete and consistent before Step 2.
10. Context bundle must be assembled and passed for every repair iteration.

## L1 快速通道

L1 跳过：Step 1.5 / Step 6
L1 流程：Step 1 → Step 2 → Step 2.5 → Step 3 → Step 5 → Step 7
- Step 3 额外输出 `"upgrade": null | "L2"`
- upgrade = "L2" → 从 Step 1.5 重新开始

## HALT 处理

Epoch > 3 或任何步骤超过 30 分钟无响应：
1. 推送告警到监控群(-5131273722)
2. 通知晨星(target:1099011886)
3. 以 degraded 状态交付当前最佳快照（S3 > S2 > S1）
4. Step 7 交付状态标记为 `degraded`

## 推送规范

main 在以下节点推送到监控群(-5131273722)：
- Step 1 分配单
- Step 1.5 Spec-Kit 结果
- Step 2 开发完成
- Step 2.5 冒烟结果
- Step 3 审查结论
- Step 4 每轮结果
- Step 5 测试结果
- Step 5.5 Epoch 状态
- Step 7 交付摘要 + 通知晨星

不要依赖各 agent 自己推送。sub-agent 推送视为 best-effort，可能丢失；所有关键进度、结果、失败与告警一律由 main 统一补发到对应职能群 + 监控群。

## Do Not Simplify Away Safety Nets

Do not skip:
- Step 1.5 spec-kit gate (L2/L3)
- Step 2.5 smoke gate
- Step 3 structured cross-review
- PASS_WITH_NOTES downgrade guards
- TF return-to-review rules
- Step 5.5 restart validation gate
- HALT 30min timeout fallback

If project context conflicts with the v1.8 contract, follow the flowchart contract and report the mismatch in final delivery notes.

### 工具容错与降级机制 (Hard Requirement)

在调用外部系统（例如 `nlm-gateway.sh` 查知识、或是其他需要认证/环境准备的 CLI 依赖）时，如果系统抛出环境或权限错误（如 `auth_missing`、`auth_expired`、`cli_error`）：
- **绝对禁止** 因此中断整个星链流水线或陷入原地死循环。
- main 或执行的子 agent 必须做**优雅降级 (Graceful Degradation)**：
  1. 发送一条 Warning 告警到监控群（-5131273722）。
  2. 直接跳过这个失败的工具调用，回退到依靠自身模型权重或常规搜索。
  3. 继续无缝推进到流水线的下一步。

---

## 优化方案总览（v1.8+）

基于《Claude Code多Agent架构实战：量化工程的三权分立》的深度分析，星链流水线实施了 11 个优化方案，分为 P0（质量优先）、P1（数据驱动）、P2（效率提升）三个优先级。

### P0：质量优先（立即生效）

**P0-1: Step 2.5 冒烟测试标准化** (`references/smoke-test-checklist.md`)
- 明确核心路径、边界条件、依赖检查清单
- 结构化失败报告（category/item/error/location/suggestion）
- 失败分类处理：语法错误自修复 vs 逻辑错误进入 Step 4
- **预期**：Step 5 失败率降低 30%

**P0-2: Step 3 性能基准对比** (`references/performance-baseline.md`)
- 测量响应时间、内存使用、依赖调用次数
- 劣化阈值：+20% 时间、+30% 内存、+50% 调用
- 性能劣化触发 NEEDS_FIX，进入 Step 4 修复
- **预期**：避免性能劣化进入生产环境

**P0-3: 异常分类和快速失败** (`references/exception-classification.md`)
- 三层分类：可恢复（重试3次）、不可恢复（立即HALT）、降级（优雅跳过）
- 可恢复：LLM超时、API限流、网络错误
- 不可恢复：认证失败、配置错误、权限不足
- 降级：NotebookLM/Gemini不可用、性能测量失败
- **预期**：无效重试成本降低 10-15%，异常恢复时间缩短 50%

### P1：数据驱动（1-2周内）

**P1-1: Step 1 分级量化模型** (`references/classification-model.md`)
- 复杂度评分：files×10 + lines×0.1 + depth×20 + risk×50
- 阈值：L1<100, L2:100-299, L3≥300
- 历史追踪（classification-history.json）+ 月度校准
- **预期**：分级准确率提升 20%

**P1-2: Epoch 决策置信度评分** (`references/epoch-confidence.md`)
- 置信度 = 历史成功率 × 相似度权重
- 失败模式关键词匹配 + 相似场景查询
- 低置信度(<0.5)触发 P1 告警 + 人工介入
- **预期**：Epoch 成功率提升 15-20%

**P1-3: 成本预算和超支告警** (`references/cost-budget.md`)
- 分级预算：L1:50k / L2:200k / L3:500k tokens
- 实时追踪（cost-tracking.json）+ 超支告警
- 告警阈值：80%→P2, 100%→P1+降级, 120%→P0+强制降级
- 降级策略：thinking=low, 跳过可选步骤, 限制 Step 4 轮次
- **预期**：成本可控，避免超预期消耗

**P1-4: monitor-bot 告警分级** (`references/monitor-alert-levels.md`)
- 四级体系：P0(立即)/P1(1h)/P2(24h)/P3(信息)
- 异常聚合（5分钟窗口）+ 告警抑制
- 路由规则：P0/P1→监控群+晨星，P2→监控群
- **预期**：告警信噪比提升 50%

### P2：效率提升（1个月内）

**P2-1: Step 4 增量审查模式** (`references/incremental-review.md`)
- R1/R2 使用增量审查（只审查本轮修改）
- R3 使用完整审查（全面检查）
- 强制完整审查触发：副作用WARNING、文件>5、行数>100、critical issue
- Verdict 合并逻辑（更新已修复 issues，添加新 issues）
- **预期**：Step 4 审查时间减少 40%，成本节省 33%

**P2-2: 任务指纹缓存机制** (`references/task-cache.md`)
- SHA256 指纹生成（keywords + files + dependencies）
- 相似度匹配（阈值 0.8）+ TTL 失效（7天）
- 缓存 Step 1.5 研究结果和 Step 6 文档模板
- 依赖变更/文件结构变更自动失效
- **预期**：相似任务成本节省 20-30%

**P2-3: 全流程 Thinking Level 审计** (`references/thinking-level-audit.md`)
- 基于 100+ 任务历史数据的成本-质量分析
- 优化建议：Step 1 high→medium, Step 1.5 review high→medium, Step 6 docs high→medium
- A/B 测试验证 + 动态调整策略
- 配置文件：workspace/thinking-level-config.json
- **预期**：成本降低 8-12%，质量影响 <3%

**P2-4: Step 1.5 依赖管理优化** (`references/step-1.5-dependencies.md`)
- 部分并行执行：珊瑚 → 织梦（使用珊瑚输出）→ review → brainstorming
- 依赖声明（YAML 配置）+ 拓扑排序
- 可选任务失败优雅降级
- **预期**：质量提升 10%，执行时间 12 分钟（vs 5 分钟完全并行）

### 累计预期收益

**质量提升**：
- Step 5 失败率降低 30%
- Epoch 成功率提升 15-20%
- 分级准确率提升 20%
- Step 1.5 质量提升 10%

**成本优化**：
- P0: 无效重试 -10-15%
- P1: 预算控制 -10-15%
- P2: 增量审查+缓存+Thinking Level -10-15%
- **总计：30-40% 成本降低**

**效率提升**：
- Step 4 审查时间 -40%
- 异常恢复时间 -50%
- 告警信噪比 +50%

### 实施状态

所有优化方案的详细文档已完成，位于 `references/` 目录：
- 冒烟测试、性能基准、异常分类（P0）
- 分级模型、Epoch置信度、成本预算、告警分级（P1）
- 增量审查、任务缓存、Thinking Level审计、依赖管理（P2）

**下一步**：
1. 更新所有 agent 的 AGENTS.md，确保了解新规范
2. 实际任务测试验证
3. 建立监控仪表板
4. 持续优化（月度审计、季度校准）
