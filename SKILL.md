---
name: starchain
description: 星链（StarChain）多 agent 开发流水线 v2.9。适用于“用星链实现 XXX”这类中高复杂度开发/修复任务，也适用于需要先产品打磨、再轻量规划、再决定是否进入完整重链的任务。由 main 在主会话逐步编排 founder-office-hours / autoplan-lite / gemini / notebooklm / openai / claude / brainstorming / coding / test / docs，支持 Lite 快车道、Full 主链、质量门和交付后短复盘。
---

# StarChain v2.9

把这项 skill 视为 **多 agent 开发编排 skill**，不是脚本启动器。

## Required Read

先读：
1. `references/pipeline-v2-9-contract.md` — 当前正式执行合约
2. `references/PIPELINE_FLOWCHART_V2_9_EMOJI.md` — 当前流程图

按需再读：
- `references/pipeline-v2-8-contract.md` — 上一正式版本，供比对/回滚参考
- `references/PIPELINE_FLOWCHART_V2_8_EMOJI.md` — 旧版流程图，仅作比对参考
- `references/pipeline-v2-7-contract.md` — 更旧版本，仅回看参考

## Current Boundary

- 当前正式版本：**v2.9**
- 上一版本：**v2.8**
- 执行模式：**main 在主会话逐步 spawn 各 agent**
- 默认入口：用户说 **“用星链实现 XXX”**
- 适用任务：中高复杂度开发、修复、跨模块改动、架构决策、需要多 agent 交叉审查的实现任务
- 新增能力：**Lite 快车道 + 前置产品打磨层 + 更硬的质量门 + 交付后短复盘层**
- 官方插件层：`founder-office-hours`、`autoplan-lite`、`review-gate`、`qa-browser-check`、`release-retro` 视为 StarChain 官方插件集；现已收编到 `starchain/plugins/`

## Trigger Guide

在这些场景触发：
- “用星链实现 XXX”
- “星链开发 / 修复 XXX”
- 需要先做产品打磨，再决定是否进入实现
- 需要中等复杂度任务的轻量规划链
- 需要 Constitution-First 打磨层
- 需要 Spec-Kit 落地后再开发
- 需要 coding / review / test / docs 多 agent 接力
- 需要高风险实现的双审 / 仲裁 / Epoch 诊断

不适用：
- 单行小修、单文件低风险改动
- 纯读代码 / 纯读文档
- 与开发实现无关的普通问答
- 已经明确是 L1 且无需编排的请求

## Route Selection

### L1
- main 直接处理，或单 agent 处理
- 不进入星链

### L2
- 默认优先走 **StarChain Lite**
- 如发现跨模块架构、高风险、重研究依赖、方案不收敛，再升级到 **StarChain Full**

### L3
- 默认直接走 **StarChain Full**
- `founder-office-hours` 默认开启

## Core Route

## Path A — StarChain Lite

适用于：
- L2
- 中等复杂度功能
- 需要规划但不值得 full chain
- 需要先收 scope 再决定是否开发

默认顺序：
1. **Step 1** — main 分级
2. **Step 1A** — `founder-office-hours`（按需；方向不清 / scope 过大时优先）
3. **Step 1B** — `autoplan-lite`
4. **Step 2** — `coding`
5. **Step 3** — `review-gate`
6. **Step 4** — `test` 或 `qa-browser-check`（UI / workflow 任务优先插入 browser QA）
7. **Step 5** — `docs`（按需）
8. **Step 6** — main 汇总交付
9. **Step 7** — main 可靠通知
10. **Step 8** — `release-retro`（按需）

## Path B — StarChain Full

适用于：
- L3
- 跨模块 / 高风险 / 高不确定性
- 需要 Constitution-First 深打磨
- 需要 Spec-Kit 四件套
- 需要多 agent 深协作

默认顺序：
1. **Step 1** — main 分级
2. **Step 1A** — `founder-office-hours`（L3 默认）
3. **Step 1.5** — Constitution-First 打磨层
4. **Step 1.5S** — Spec-Kit 落地
5. **Step 2** — `coding`
6. **Step 3** — `review-gate`
7. **Step 4** — `test` / `qa-browser-check`
8. **Step 5** — `docs`
9. **Step 6** — main 汇总交付
10. **Step 7** — main 通知
11. **Step 8** — `release-retro`（按需）

## Step Definitions

### Step 1 — main 分级
main 自己完成：
- 任务分级：L1 / L2 / L3
- 类型分析：Type A / Type B
- 是否走 Lite 或 Full
- 是否需要前置产品打磨层

### Step 1A — Product Framing Layer
由 `founder-office-hours` 执行，目标是先回答：
- 值不值得做
- 最小 wedge 是什么
- 哪些 scope 应该先砍
- build / shrink / defer / reject

默认触发：
- L3 默认开启
- L2 在方向不清、scope 明显过大、存在“可能做错问题”风险时开启

### Step 1B — Lite Planning Layer
由 `autoplan-lite` 执行，目标是形成轻量可执行计划：
- Goal
- Scope in / out
- Assumptions
- Risks
- Execution path
- Ordered task list
- Open decisions

默认触发：
- L2 默认开启
- Full 路径可跳过，或作为预判层使用

### Step 1.5 — Constitution-First 打磨层
默认顺序：
1. `gemini` — 扫描歧义 / 风险 / 边界
2. `notebooklm` — 提供历史经验 / 模板 / 常见坑点
3. `openai` — 定宪法（约束，不写方案）
4. `claude` — 出实施计划（主方案）
5. `gemini` — 一致性复核
6. `openai` / `claude` — 按需仲裁

### Step 1.5S — Spec-Kit 落地
由 `brainstorming` 产出：
- `spec.md`
- `plan.md`
- `research.md`
- `tasks.md`
- `analyze` 一致性检查

### Step 2 — Build
- `coding` — 开发执行

### Step 3 — Review Gate
默认用 `review-gate` 代替松散 review。目标不是给建议，而是做 gate：
- correctness
- regression risk
- completeness gap
- required validations
- recommended next step

允许 verdict：
- Pass
- Pass with follow-ups
- Needs fixes before QA
- Blocked

### Step 4 — QA / Test
- 代码 / 逻辑型任务 → `test`
- UI / workflow / browser-visible 任务 → `qa-browser-check`
- 两者都需要时 → 先 `test` 再 `qa-browser-check`

### Step 5 — Docs / Delivery Prep
- `docs` 按需触发

### Step 6 — main 汇总交付
- main 汇总关键结果、风险、下一步动作

### Step 7 — main 通知
- main 统一补发可靠通知
- 监控群 + 晨星 DM 为主链路

### Step 8 — Release Retro
由 `release-retro` 按需执行，提炼：
- what worked
- what hurt
- repeated patterns
- what to record/promote
- immediate follow-ups

## Escalation / Downgrade Rules

### Lite 升级到 Full 的条件
满足任一条就升级：
- 出现跨模块架构问题
- 需要重研究
- 涉及安全 / 权限 / 数据迁移
- 方案冲突明显
- `autoplan-lite` 无法稳定收敛
- 晨星明确要求 full chain

### 降级条件
- 单文件修改
- 普通 bug
- 小功能补丁
- 已有成熟路径的重复性实现
- 明显属于 L1

## Agent Roles

- **main**：顶层编排、分级、补发通知、最终交付、Lite/Full 路由选择
- **founder-office-hours**：产品打磨、wedge 判断、scope 收缩、build/shrink/defer 建议
- **autoplan-lite**：L2 轻量规划、风险收敛、执行路径产出
- **gemini**：扫描、反方 review、一致性检查
- **notebooklm**：历史知识 / 模板 / 经验补料
- **openai**：宪法定稿、冲突仲裁
- **claude**：主计划、主审查、复杂实现路径
- **brainstorming**：Spec-Kit 四件套、方案智囊
- **coding**：开发执行
- **review-gate**：质量门 verdict
- **test**：测试执行
- **qa-browser-check**：浏览器关键路径 QA
- **docs**：文档交付
- **release-retro**：交付后短复盘与沉淀

## Model / Risk Rules

### 何时用 Full 链路
- 跨模块改动
- 安全 / 权限 / 数据迁移
- 高影响线上修复
- 复杂架构决策
- 外部方案吸收并本地化落地
- `autoplan-lite` 不能稳定收敛的任务

### 何时优先 Lite
- L2 功能规划
- 中等复杂度改造
- 先规划后决定是否开发
- 自动化 / 工作流设计
- 需要可执行方案但不值得 full research 的任务

### 独立性规则
- **Gemini 不做最终仲裁**
- **谁主写，谁尽量不终审**
- Claude 主方案 → 优先 GPT 仲裁
- GPT 主方案 → 优先 Claude 仲裁
- `review-gate` 给 gate verdict，不能被 coding announce 替代

## Hard Rules

- **不要**用废弃 launcher 脚本当默认入口
- **不要**把 main 再套成 isolated session 去编排 main 自己
- **不要**让 review 反向编排其他 agent
- **不要**把 agent 自推当成可靠通知
- **不要**让 coding 的 announce 直接充当完成证明
- **不要**把 5 个新增 skill 机械地每步全跑一遍
- **不要**为了保持仪式感让 L1 任务进入星链
- **不要**跳过质量门后直接宣称完成

## Spawn Rules

主模式：
```text
main 在主会话中逐步 sessions_spawn(mode="run") 各 agent
```

重试规则：
1. 第一次失败 → 立即重试
2. 第二次失败 → 10 秒后重试
3. 第三次失败 → 告警 + BLOCKED

## Notification Rules

- 每次 spawn 后，main 立即补发“开始”通知
- agent 返回后，main 立即补发“完成 / 失败”通知
- Step 7 由 main 统一推送到监控群与晨星
- agent 自推永远是 best-effort，**main 补发才是可靠链路**

## Version Policy

- 只保留：**当前版本 + 上一版本**
- 当前：`v2.9`
- 上一版：`v2.8`
- 更老版本、旧 flowchart、旧 README / CHANGELOG / launcher 文档应清理，避免 prompt drift

## When To Read More

- 需要正式执行约束 → 读 `references/pipeline-v2-9-contract.md`
- 需要看当前流程顺序 → 读 `references/PIPELINE_FLOWCHART_V2_9_EMOJI.md`
- 需要回看旧正式链路 → 读 `references/pipeline-v2-8-contract.md`
- 需要看旧流程顺序 → 读 `references/PIPELINE_FLOWCHART_V2_8_EMOJI.md`
- 需要更老版本回滚/核对 → 读 `references/pipeline-v2-7-contract.md`
