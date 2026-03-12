---
name: starchain
description: 星链（StarChain）— OpenClaw 多 agent 协作锻造流水线 v2.8。NotebookLM 深度参与打磨层，证据驱动规则，Brainstorming 动态模型。从 Step 1 分级到 Step 7 交付的全自动编排，统一角色分工（Gemini 扫描 → NotebookLM 深度研究 → GPT-5.4 宪法 → Claude 计划 → Gemini 复核 → OpenAI/Claude 仲裁 → Brainstorming 落地 Spec-Kit）。提升效率 30-40%，降本 35-45%，Epoch 成功率提升 15-20%。
---

# 星链 StarChain v2.8

星链是 OpenClaw 的多 agent 协作流水线，采用 Launcher Script 一键启动模式，main（小光）不在私聊里串联，符合"主私聊不承载长编排"约束。

使用本 skill 执行开发和修复任务，遵循 `references/pipeline-v2-8-contract.md` 中的流水线合约。

## 快速参考

### 一句话
**Launcher Script 一键启动 → Gemini 扫问题 → NotebookLM 深度研究 → GPT-5.4 定规则 → Claude 出计划 → Gemini 复核 → Spec-Kit 落地**

### 快速启动

```bash
# 一键启动星链流水线
~/.openclaw/skills/starchain/scripts/starchain-launcher.sh \
  "实现用户登录功能" \
  L2

# 带项目路径
~/.openclaw/skills/starchain/scripts/starchain-launcher.sh \
  "优化数据库查询性能" \
  L3 \
  ~/projects/myapp
```

### v2.8 核心改进

1. **NotebookLM 提前介入**：从 Step 1.5S 移到 Step 1.5B，在制定宪法之前提供历史经验
2. **证据驱动规则**：宪法基于 NotebookLM 的历史教训制定，避免重复踩坑
3. **Brainstorming 动态模型**：根据任务级别和轮次动态选择 sonnet/opus
4. **与星鉴统一**：NotebookLM 深度参与模式与星鉴流水线一致

### v2.7 核心改进

1. **Launcher Script 模式**：Main 不再在私聊里串联，改用一键启动脚本
2. **主私聊不占线**：符合"主私聊不承载长编排"约束
3. **统一独立性规则**：与星鉴流水线统一仲裁规则

### 三模型职责
- **Gemini（织梦）**: 扫描歧义/边界/风险 + 反方 review（不定规则、不仲裁）
- **GPT-5.4（openai）**: 宪法定稿 + 冲突仲裁（不写方案）
- **Claude（小克）**: 主方案 + 复杂实现路径（不仲裁）
- **Review**: 正式审查（单一审查任务，不再编排其他 agent）
- **Coding/Test**: 执行开发和测试（不参与裁决）

### 何时启用三模型
- 跨模块改动、安全/权限、数据迁移、支付/交易
- 高影响线上修复、复杂架构决策、外部方案吸收与本地化落地

### 何时降级
- 单文件修改、普通 bug、小功能补丁
- 低风险脚本/文档任务、已有成熟路径的重复性实现

### 降级策略
- **普通任务**: GPT-5.4 → Claude 或 GPT-5.4 → coding → test
- **中风险任务**: Gemini → GPT-5.4 → Claude → Gemini
- **高风险任务**: Gemini → GPT-5.4 → Claude → Gemini → GPT-5.4

### 仲裁独立性规则
- Claude 主方案 → GPT-5.4 仲裁
- GPT-5.4 主方案 → Claude 仲裁
- Gemini 始终不做最终仲裁，只做证据和反方意见
- **原则**: 谁主写，谁尽量不终审

### 完成判定
- ✅ 文件已落地
- ✅ 结构化回执已返回
- ✅ 通知已发出或由 main 补发
- ⚠️ 缺一项都不算真正完成

---

## When This Skill Triggers

Trigger this skill when the user asks to:
- run the cross-review pipeline
- assign work across coding/test/docs/monitor/brainstorming/gemini/claude
- enforce Step 1.5 + 1.5S constitution/spec-kit gates
- handle Step 3/4/5 verdict loops and Epoch fallback
- create constitutions/plans/tasks for a feature

## Required Read

Before execution, read:
1. `references/pipeline-v2-8-contract.md` — v2.8 流水线合约（必读）
2. `references/pipeline-v2-7-contract.md` — v2.7 合约（回滚参考）

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

## Architecture: Launcher Script 模式

**一键启动，全自动推进。** Main 调用 `scripts/starchain-launcher.sh` 启动流水线，脚本内部自动串联所有步骤。

```
main（小光）
└── exec ~/.openclaw/skills/starchain/scripts/starchain-launcher.sh "<任务>" <L1|L2|L3> [project-path]
    ├── Step 1：任务分级 + 类型分析（脚本记录）
    ├── Step 1.5：Constitution-First 打磨层
    │   ├── openclaw agent --agent gemini → 扫描
    │   ├── openclaw agent --agent openai → 宪法
    │   ├── openclaw agent --agent claude → 计划
    │   ├── openclaw agent --agent gemini → 一致性复核
    │   └── openclaw agent --agent openai/claude → 仲裁（按需）
    ├── Step 1.5S：NotebookLM 深度研究 + Spec-Kit 落地
    │   ├── openclaw agent --agent notebooklm → 历史经验查询
    │   └── openclaw agent --agent brainstorming → Spec-Kit 四件套
    ├── Step 2：openclaw agent --agent coding → 开发（含 Step 2.5 冒烟）
    ├── Step 3：并行 spawn claude + gemini → 双审
    ├── Step 4：循环修复（max 3 rounds）
    ├── Step 5：openclaw agent --agent test → 测试
    ├── Step 5.5：Epoch 诊断与仲裁（按需）
    ├── Step 6：openclaw agent --agent docs → 文档
    └── Step 7：main 汇总交付 + 通知晨星

**优势**：
- Main 不在私聊里等待和轮询
- Launcher 自动串联，无需手动编排
- 符合"主私聊不承载长编排"约束
- NotebookLM 深度研究提供历史经验
```

### Workspace 架构

**Main Agent 工作目录**：
- `~/.openclaw/workspace/` - Main agent (小光) 的工作目录
- `workspace/intel/` - Agent 协作层（单写者原则）
  - `collaboration/` - 多 agent 联合工作的非正式产物（外部项目、本地镜像、共享分析素材等）
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
- 多 agent 联合工作的非正式产物（外部 GitHub 项目、本地镜像、共享分析素材等）统一放到 `intel/collaboration/`
- Main agent 或其他 agent 直接读取对应 agent 的 workspace 目录获取完整产物

### 知识层集成（珊瑚 NotebookLM）
- Step 1.5S：在 `claude` 计划与 `review` 结论稳定后，spawn 珊瑚提供历史开发经验 / 模板补料，支撑 `Spec-Kit` 落地
- Step 6：spawn 珊瑚查询交付模板、FAQ、历史实现/交付参考
- 珊瑚通过 nlm-gateway.sh 访问 notebooks（按 ACL 权限）
- 默认 Notebook：starchain-knowledge
- 可按需上传当前任务的超长 README / 设计文档 / 外部方案原文到 starchain-knowledge 作为临时 source
- 明确不默认使用：openclaw-docs（仅限 OpenClaw 自身问题）、media-research（自媒体专用）、memory-archive（仅在明确需要回看历史开发原话时按需查询）

## Agent Roles

| Agent | Role | Key Steps |
|-------|------|-----------|
| main（小光） | 顶层编排中心 + 汇总 | Step 1, 1.5/1.5S 编排, 3 汇总, 4 编排, 5.5 编排, 7 |
| openai（GPT） | 宪法制定 + 仲裁 | Step 1.5B(最终宪法), Step 1.5E(仲裁), Step 3(分歧仲裁), Step 5.5(按需仲裁回滚) |
| claude（小克） | 实施计划 + 主审查 + 独立复核 | Step 1.5C(基于宪法出计划), Step 3(主审查), Step 5.5(独立诊断复核) |
| gemini（织梦） | 扫描 + Adversarial Review | Step 1.5A(扫描), Step 1.5D(复核), Step 3(找漏洞), Step 4(预审), Step 5.5(诊断), Step 6(大纲) |
| coding | 开发执行 | Step 2, 2.5, 4(fix), TF(fix) |
| test | 测试执行 | Step 5, TF(rerun), Epoch(test) |
| brainstorming | 方案智囊 | Step 1.5S(Spec-Kit 四件套), 4(方案), TF-2/3(方案), 5.5(回滚决策) |
| docs | 文档生成 | Step 6 |
| 珊瑚(notebooklm) | 知识查询 | Step 1.5S(知识/模板补料), Step 6(文档模板) |
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

## Spec-Kit Integration (Step 1.5S / Step 2 Gate)

L2/L3 tasks must first complete Constitution-First（final constitution + approved plan + review verdict）, then pass the Step 1.5S gate before Step 2. The workflow:
1. `notebooklm` → `reports/step-1.5-knowledge.md` (历史知识 / 模板补料)
2. `specify` → `specs/{feature}/spec.md` (WHAT/WHY, no HOW)
3. `plan` → `specs/{feature}/plan.md` + `research.md` (packaging the approved plan with supporting rationale)
4. `tasks` → `specs/{feature}/tasks.md` (ordered, dependencies marked, [P] for parallel)
5. `analyze` → consistency check (`spec ↔ plan ↔ tasks ↔ constitution`)

Critical consistency issues block Step 2. Brainstorming agent executes; main orchestrates; coding uses `tasks.md` as the default execution entry.

### Gemini / NotebookLM Inputs (Default: enabled for L2/L3)
- Step 1.5A: gemini scan artifacts feed the constitution and later fold into `research.md`.
- Step 1.5S: notebooklm supplement is folded into `plan.md` / `research.md` during packaging.
- Step 6: before spawning docs, main spawns gemini to draft release-notes/FAQ outline; include as docs input.
- Step 5.5: when entering Epoch/HALT, main spawns gemini to summarize failure logs into a diagnosis memo for monitor-bot + delivery notes.

Legacy inspiration: https://github.com/github/spec-kit

## Main 编排流程（逐步执行）

### Step 1：分级 + 类型分析 + 风险判断
main 自己执行：
1. 判断等级：L1 / L2 / L3
   - L1：简单修复、配置调整、文档更新
   - L2：标准功能开发、中等复杂度重构
   - L3：大型功能、架构重构、跨模块变更
2. 判断类型：A / B / C → 确定各 agent 模型配置
3. **判断风险（L2 only）**：低风险 / 高风险
   - **低风险**：单模块、无架构变更、无外部依赖变更、历史成功率 >80%
   - **高风险**：跨模块、架构变更、新技术栈、关键路径、安全相关
4. 推送分配单到监控群(-5131273722)
5. 路由：
   - L1 → 快速通道
   - L2-低风险 → Step 1.5 + 1.5S 标准链（`claude/sonnet/medium` 方案位，按 drift / 强分歧触发仲裁）
   - L2-高风险 → Step 1.5 + 1.5S 标准链（`claude/opus/medium` 方案位，提高仲裁敏感度）
   - L3 → Step 1.5 + 1.5S 强化链（`claude/opus/medium` 方案位，默认允许独立仲裁）

**成本优化策略（质量优先）**：
- L1：跳过 Step 1.5 / 1.5S / Step 6
- L2/L3：不跳过主链，只通过 Thinking Level / 仲裁敏感度做成本优化
- **通过 Thinking Level 优化成本**：
  - Step 1.5: thinking="medium"（低/中风险），高风险按需升档
  - Step 4 R1: thinking="low" (快速方案)
  - Step 4 R2: thinking="medium" (更多思考)
  - Step 4 R3: thinking="high" + opus (深度分析)
  - 预期降本 10-15%

### Step 1.5：Constitution-First 打磨层（L2/L3）
main 编排：

**一句话总结**：Gemini 扫问题 → GPT-5.4 定规则 → Claude 出计划 → Review/Gemini 挑刺 → Review/OpenAI/Claude 仲裁

**标准链（L2/L3）：**

1️⃣ **spawn 织梦（gemini）**
   - 需求颗粒度扫描
   - 输出：歧义、边界、风险、默认假设
   - 输出路径：`agents/gemini/reports/*-scan-*.md`

2️⃣ **spawn openai（GPT-5.4）**
   - 基于 gemini 扫描结果写最终宪法
   - 输出：目标、非目标、硬约束、验收、红线
   - 输出路径：`agents/openai/reports/*-constitution-*.md`

3️⃣ **spawn 小克（claude）**
   - 按宪法出实施计划
   - L2-低风险默认：`claude/sonnet/medium`
   - L2-高风险 / L3 默认：`claude/opus/medium`
   - 输出：方案、影响面、依赖、测试、回滚
   - 输出路径：`agents/claude/reports/*-plan-*.md`

4️⃣ **spawn review（内部 spawn gemini）**
   - 一致性复核（adversarial review）
   - 输出：ALIGN / DRIFT / MAJOR_DRIFT
   - 输出路径：`agents/review/reports/*-review-*.md`

5️⃣ **按需 spawn review（内部 spawn openai 或 claude）**
   - 触发条件：L3 / MAJOR_DRIFT / 高风险分歧
   - 输出：GO / REVISE / BLOCK
   - 遵循仲裁独立性规则：谁主写，谁尽量不终审

**判定：**
- ALIGN / GO ✅      → 进入 Step 1.5S（Step 2 gate）
- DRIFT / REVISE ⚠️  → Claude 修订 1 次 → review/gemini 复审 → 再判定
- MAJOR_DRIFT / BLOCK ❌ → main 推送阻塞原因 → HALT / 降级交付

**规则（v2.5）：**
- 🚫 不新增晨星中途确认节点，全自动推进
- 🚫 这条前置链不替换后续开发 / 审查 / 测试主干
- ✅ Gemini 先扫描，GPT-5.4 基于扫描结果定宪法（避免盲目定规则）
- ✅ Claude 专注主方案设计
- ✅ review/gemini 做一致性复核
- ✅ review/openai 默认仲裁；若 GPT 同源则切到 claude 仲裁
- ✅ 这是 v2.5 对角色分工和仲裁独立性的统一收口

### Step 1.5S：NotebookLM 补料 + Spec-Kit 落地（Step 2 Gate）
main 编排：

1️⃣ **spawn 珊瑚（notebooklm）**
   - 在 `claude` 计划与 `review` 结论稳定后补充历史知识 / 模板
   - 输出路径：`agents/notebooklm/reports/step-1.5-knowledge.md`

2️⃣ **spawn brainstorming**
   - 基于最终宪法、已批准计划、review 结论与 notebooklm 补料
   - 默认使用 `sonnet/think medium` 落地 `spec.md` / `plan.md` / `tasks.md` / `research.md`
   - 若为 L2-高风险 / L3、刚经历仲裁，或 `analyze` 需要重跑，则升级为 `opus/think high`
   - 输出路径：`agents/brainstorming/specs/{feature}/`

3️⃣ **run analyze**
   - 检查 `spec ↔ plan ↔ tasks ↔ constitution` 一致性
   - critical consistency issues → 阻塞 Step 2

**判定：**
- PASS ✅             → Step 2
- REVISE ⚠️           → brainstorming 修订后重跑 `analyze`
- BLOCK ❌            → main 推送阻塞原因 → HALT / 降级交付

**规则（v2.5）：**
- ✅ `Spec-Kit` 是默认主链，不是可选 companion
- ✅ `NotebookLM` 默认保留，为 `Spec-Kit` 提供知识补料
- ✅ `coding` 默认以 `tasks.md` 作为执行入口，并同时遵守最终宪法与已批准计划

### Step 2 + 2.5：开发 + 冒烟
main 编排：
1. spawn coding → 按最终宪法 + 已批准计划 + tasks.md 开发 + 自执行冒烟测试
2. coding announce 回来后，main 检查结果
3. **冒烟测试结果处理（优化：失败分类）**：
   - **PASS** → 创建 S1 快照，进入 Step 3
   - **FAIL** → coding 分析失败类型：
     - **语法/编译错误**：coding 自修复（max 2 次）
       - 修复成功 → 创建 S1 快照，进入 Step 3
       - 2 次仍失败 → 进入 Step 4（带详细错误日志）
     - **逻辑/功能错误**：直接进入 Step 4（带详细测试日志）
   
**优化收益**：减少 20% 的 Step 4 进入次数，简单语法错误快速自修复

### Step 3：交叉审查 + Gemini Adversarial（强制）
review 内部编排，main 只接收结构化 verdict：

**Type A（业务/架构）：**
1. spawn 小克（claude）→ 主审查 / 结构化交叉审查
   - L2-低风险默认 `claude/sonnet/medium`
   - 其他场景按现有高档位执行
2. spawn 织梦（gemini）/think medium → Adversarial review（专职找漏洞）
3. review 汇总两者结果 → 综合判定：
   - 两者都 PASS → 创建 S2 快照，进入 Step 5
   - 任一 ISSUES_FOUND → 进入 Step 4

**Type B（算法/性能）：**
1. spawn 小克（claude）/think medium → 算法分析 + 性能审查
   - L2-低风险默认可降到 `claude/sonnet/medium`
2. spawn 织梦（gemini）/think medium → Adversarial review（找算法漏洞）
3. review 汇总两者结果 → 综合判定：
   - 两者都 PASS → 创建 S2 快照，进入 Step 5
   - PASS_WITH_NOTES → minor fix diff ≤ G2 免审 → S2 → Step 5；diff > G2 降级 ISSUES_FOUND
   - 任一 ISSUES_FOUND → 进入 Step 4

**分歧仲裁（按需触发）：**
触发条件（满足任一）：
- Claude 和 Gemini 判定相反
- 分歧点 ≥ 2
- 关键问题分歧（severity = critical）
- Coder 反驳审查结论

spawn review（swap openai|claude）/think high
  → 由 review 按固定 rubric 和独立性规则编排仲裁
  → 逐条裁决，不能笼统说"我同意A"
  → 仲裁群 + 监控群

**优化收益（v2.5）**：
- Claude 做主审查，Gemini 做 adversarial review，误差不相关
- L2-低风险审查位默认可降到 `claude/sonnet/medium`，不改变双审结构
- 仲裁继续由 `review` 收口编排，不直接从主链跳 `openai`
- 代码出来后再做 adversarial review，更容易发现实际问题
- 预计发现问题的覆盖率提升 20-30%

**Spawn 示例：**
```javascript
// Step 3 主审查（由 review 内部编排）
sessions_spawn(
  agentId: "review",
  model: "anthropic/claude-sonnet-4-6",
  thinking: "medium",
  task: "L2-低风险主审查，按结构化 rubric 检查代码..."
)

// Step 3 仲裁（由 review 内部选择 openai 或 claude）
sessions_spawn(
  agentId: "review",
  model: "openai/gpt-5.4",
  thinking: "high",
  task: "按仲裁 rubric 逐条裁决审查分歧..."
)
```

### Step 4：修复循环 + Gemini 预审（max 3 rounds）
main 编排每轮：

1. 组装 context bundle（需求 + diff + issues JSON + 前轮反馈）
2. spawn brainstorming → 出修复方案
3. spawn coding → 执行修复
4. **spawn review（swap gemini）→ 快速预审**
   - 发现明显问题（语法错误、逻辑漏洞、需求偏离）
   - 预审 PASS → 进入 Step 4.5（正式复审）
   - 预审 FAIL → 直接进入下一轮修复，不进入正式复审
5. **Step 4.5：正式审查**
   - 仅在预审 PASS 时进入
   - R1 / R2：增量复审（只审本轮 diff + 未解决 issues）
   - R3：全量复审（回到 Step 3 的完整双审标准）

**模型与 Thinking Level 配置（质量优先 + 成本优化）**：
- R1: brainstorming sonnet/low + coding gpt/medium + review/gemini 预审
- R2: brainstorming sonnet/medium + coding gpt/medium + review/gemini 预审
- R3: brainstorming opus/high + coding gpt/xhigh + review/gemini 预审
- 正式复审：R1/R2 增量，R3 全量
- R3 仍 NEEDS_FIX → Step 5.5

**优化收益**：
- gemini 预审可提前发现 30-40% 的明显问题
- 避免浪费 gpt/sonnet 的高成本审查
- 预审 FAIL 不再空转进入正式复审
- R1/R2 增量复审，R3 全量复审，兼顾速度与覆盖率
- 预计降本 15-20%

**Spawn 示例：**
```javascript
// Step 4.4: gemini 预审
sessions_spawn(
  agentId: "review",
  model: "gemini/gemini-3.1-pro-preview",
  thinking: "medium",
  task: "快速预审修复代码，发现明显问题..."
)
```

### Step 5.5：Epoch 回退 + 增强诊断（max 3 Epochs）
main 编排：

1. **spawn gemini（织梦）/think high** → 产出诊断 memo
   - 快速分析失败模式
   - 识别根本原因
   - 输出路径：`agents/gemini/reports/*-diagnosis-*.md`

2. **spawn review（swap claude）/think medium** → 独立复核诊断
   - 默认 `claude/sonnet/medium`
   - L2-高风险 / L3 / Epoch >= 2 升级为 `claude/opus/medium`
   - 检查诊断是否遗漏关键信息
   - 补充遗漏的失败模式
   - 输出：COMPLETE / INCOMPLETE

3. **spawn brainstorming（opus）/think high** → 根因分析 + 回滚决策
   - 输入：诊断 memo + 复核结果 + 历史决策数据（epoch-history.json）
   - 分析根本原因
   - 决定回滚策略：S1 / S2 / 继续
   - 输出：回滚决策 + 理由

4. **spawn review（swap openai|claude）/think high** → 仲裁回滚决策（高风险场景）
   - 默认 `openai`
   - 若需规避 GPT 同源或满足独立性规则则切换 `claude`
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
- gemini 负责发散诊断，claude 负责独立复核，避免同源偏差
- review/openai|claude 仲裁回滚决策，避免错误回滚
- Epoch 成功率提升 15-20%（原 10-15%）

**Spawn 示例：**
```javascript
// Step 5.5.1: gemini 诊断
sessions_spawn(
  agentId: "gemini",
  thinking: "high",
  task: "分析测试失败日志，产出诊断 memo..."
)

// Step 5.5.2: review/claude 独立复核诊断
sessions_spawn(
  agentId: "review",
  model: "anthropic/claude-sonnet-4-6",
  thinking: "medium",
  task: "独立复核诊断 memo，检查是否遗漏关键信息..."
)

// Step 5.5.3: brainstorming 根因分析
sessions_spawn(
  agentId: "brainstorming",
  model: "anthropic/claude-opus-4-6",
  thinking: "high",
  task: "基于诊断 memo 和复核结果，分析根因并决定回滚策略..."
)

// Step 5.5.4: review/openai|claude 仲裁（按需）
sessions_spawn(
  agentId: "review",
  model: "openai/gpt-5.4",
  thinking: "high",
  task: "仲裁回滚决策，评估风险..."
)
```

### Step 6：文档（L1 跳过）
main 编排：
1. **文档影响门**：先判断是否存在公开文档影响
   - **无公开文档影响**：默认只产出 `changelog` / `delivery note` / FAQ 摘要，不做 README / API / Guide 全量重写
   - **有公开文档影响**：进入完整文档链
2. **珊瑚知识查询**（完整文档链，可选）：
   - spawn notebooklm (珊瑚) → 查询 starchain-knowledge notebook
   - 任务：`查询关于 <功能名称> 的交付模板、FAQ 示例、历史类似实现/交付参考`
   - 如当前任务存在超长 README / 设计文档 / 外部方案原文，可先按需上传到 starchain-knowledge 再查询
   - 珊瑚返回文档模板、FAQ 参考和历史经验
   - 如果失败 → Spawn 重试 → Warning → 降级跳过
3. **织梦加速**：spawn 织梦(gemini, thinking="medium") → 产出交付说明/FAQ 大纲
   - 输入：最终 diff + 需求 + 珊瑚文档模板（如有）
4. **docs 生成**：spawn docs → 生成/更新文档
   - 输入：织梦大纲 + 代码 diff + 审查摘要
   - 无公开文档影响时，优先生成 `changelog` / `delivery note` / FAQ 摘要
5. 由 main 推送文档群(-5095976145) + 监控群

### Step 7：交付
main 自己执行：
1. 汇总交付摘要（scope + files + test + review + level + status + snapshots）
2. 推送监控群(-5131273722)
3. 通知晨星(target:1099011886)

## Execution Rules

0. **全自动推进，不停顿。** 除 Step 7 晨星确认外，所有步骤自动衔接，绝不暂停等待用户确认。进度推送到监控群即可，不要问"要继续吗"。
1. Always start at Step 1 (L1/L2/L3 classification + track selection).
2. L1 goes to fast lane; L2/L3 must pass Step 1.5 + Step 1.5S before Step 2.
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
9. Step 1.5 constitution artifacts and Step 1.5S Spec-Kit artifacts must be complete and consistent before Step 2.
10. Context bundle must be assembled and passed for every repair iteration.

## L1 快速通道

L1 跳过：Step 1.5 / Step 1.5S / Step 6
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
- Step 1.5 / 1.5S Constitution + Spec-Kit gate 结果
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
- Step 1.5 / 1.5S gate (L2/L3)
- Step 2.5 smoke gate
- Step 3 structured cross-review
- PASS_WITH_NOTES downgrade guards
- TF return-to-review rules
- Step 5.5 restart validation gate
- HALT 30min timeout fallback

If project context conflicts with the v2.5 contract, follow `references/pipeline-v2-5-contract.md` and report the mismatch in final delivery notes.

### 工具容错与降级机制 (Hard Requirement)

在调用外部系统（例如 `nlm-gateway.sh` 查知识、或是其他需要认证/环境准备的 CLI 依赖）时，如果系统抛出环境或权限错误（如 `auth_missing`、`auth_expired`、`cli_error`）：
- **绝对禁止** 因此中断整个星链流水线或陷入原地死循环。
- main 或执行的子 agent 必须做**优雅降级 (Graceful Degradation)**：
  1. 发送一条 Warning 告警到监控群（-5131273722）。
  2. 直接跳过这个失败的工具调用，回退到依靠自身模型权重或常规搜索。
  3. 继续无缝推进到流水线的下一步。

---

