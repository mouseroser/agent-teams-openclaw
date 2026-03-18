---
name: starchain
description: 星链（StarChain）多 agent 开发流水线 v2.8。适用于“用星链实现 XXX”这类中高复杂度开发/修复任务：由 main 在主会话逐步编排 gemini → notebooklm → openai → claude → brainstorming → coding → test → docs，执行 Constitution-First 打磨层、Spec-Kit 落地、开发/审查/测试/交付闭环。
---

# StarChain v2.8

把这项 skill 视为 **多 agent 开发编排 skill**，不是脚本启动器。

## Required Read

先读：
1. `references/pipeline-v2-8-contract.md` — 当前正式执行合约
2. `references/PIPELINE_FLOWCHART_V2_8_EMOJI.md` — 当前流程图

按需再读：
- `references/pipeline-v2-7-contract.md` — 上一版本，仅作回滚/比对参考

## Current Boundary

- 当前正式版本：**v2.8**
- 上一版本：**v2.7**（仅回看/回滚参考）
- 执行模式：**main 在主会话逐步 spawn 各 agent**
- 默认入口：用户说 **“用星链实现 XXX”**
- 适用任务：中高复杂度开发、修复、跨模块改动、架构决策、需要多 agent 交叉审查的实现任务

## Trigger Guide

在这些场景触发：
- “用星链实现 XXX”
- “星链开发 / 修复 XXX”
- 需要 Constitution-First 打磨层
- 需要 Spec-Kit 落地后再开发
- 需要 coding / review / test / docs 多 agent 接力
- 需要高风险实现的双审 / 仲裁 / Epoch 诊断

不适用：
- 单行小修、单文件低风险改动
- 纯读代码 / 纯读文档
- 与开发实现无关的普通问答

## Core Route

### Step 1 — main 分级
main 自己完成：
- 任务分级：L1 / L2 / L3
- 类型分析：Type A / Type B
- 是否需要完整前置链

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

### Step 2-6 — 执行闭环
- `coding` — 开发
- `claude` + `gemini` — 双审 / 修复回路
- `test` — 测试
- `docs` — 文档
- `main` — 汇总交付

### Step 7 — main 通知
- main 统一补发可靠通知
- 监控群 + 晨星 DM 为主链路

## Agent Roles

- **main**：顶层编排、分级、补发通知、最终交付
- **gemini**：扫描、反方 review、一致性检查
- **notebooklm**：历史知识 / 模板 / 经验补料
- **openai**：宪法定稿、冲突仲裁
- **claude**：主计划、主审查、复杂实现路径
- **brainstorming**：Spec-Kit 四件套、方案智囊
- **coding**：开发执行
- **test**：测试执行
- **docs**：文档交付

## Model / Risk Rules

### 何时用完整链路
- 跨模块改动
- 安全 / 权限 / 数据迁移
- 高影响线上修复
- 复杂架构决策
- 外部方案吸收并本地化落地

### 何时降级
- 单文件修改
- 普通 bug
- 小功能补丁
- 已有成熟路径的重复性实现

### 独立性规则
- **Gemini 不做最终仲裁**
- **谁主写，谁尽量不终审**
- Claude 主方案 → 优先 GPT 仲裁
- GPT 主方案 → 优先 Claude 仲裁

## Hard Rules

- **不要**用废弃 launcher 脚本当默认入口
- **不要**把 main 再套成 isolated session 去编排 main 自己
- **不要**让 review 反向编排其他 agent
- **不要**把 agent 自推当成可靠通知
- **不要**跳过 Step 1.5 / 1.5S 后直接开发（L2/L3 默认不允许）
- **不要**让 coding 的 announce 直接充当完成证明

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
- 当前：`v2.8`
- 上一版：`v2.7`
- 更老版本、旧 flowchart、旧 README / CHANGELOG / launcher 文档应清理，避免 prompt drift

## When To Read More

- 需要正式执行约束 → 读 `references/pipeline-v2-8-contract.md`
- 需要看流程顺序 → 读 `references/PIPELINE_FLOWCHART_V2_8_EMOJI.md`
- 需要回滚或核对旧路径 → 读 `references/pipeline-v2-7-contract.md`
