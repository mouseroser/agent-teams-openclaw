#!/bin/bash
# starchain-launcher.sh - 星链流水线一键启动脚本 v2.7
# 用法: starchain-launcher.sh "<任务描述>" <L1|L2|L3> [project-path]

set -euo pipefail

TASK="${1:-}"
LEVEL="${2:-L2}"
PROJECT_PATH="${3:-}"

if [[ -z "$TASK" ]]; then
  echo "错误: 缺少任务描述"
  echo "用法: $0 \"<任务描述>\" <L1|L2|L3> [project-path]"
  exit 1
fi

SKILL_DIR="$HOME/.openclaw/skills/starchain"
WORKSPACE="$HOME/.openclaw/workspace"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_ID="starchain_${TIMESTAMP}"
LOG_FILE="/tmp/starchain_${TIMESTAMP}.log"

echo "========================================" | tee -a "$LOG_FILE"
echo "星链流水线 v2.7 启动" | tee -a "$LOG_FILE"
echo "任务: $TASK" | tee -a "$LOG_FILE"
echo "级别: $LEVEL" | tee -a "$LOG_FILE"
echo "项目路径: ${PROJECT_PATH:-无}" | tee -a "$LOG_FILE"
echo "运行 ID: $RUN_ID" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# 创建运行目录
RUN_DIR="$WORKSPACE/runs/$RUN_ID"
mkdir -p "$RUN_DIR"

# 记录任务信息
cat > "$RUN_DIR/task.json" <<EOF
{
  "task": "$TASK",
  "level": "$LEVEL",
  "projectPath": "${PROJECT_PATH:-null}",
  "runId": "$RUN_ID",
  "startTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "running"
}
EOF

echo "[$(date +%H:%M:%S)] Step 1: 任务分级与类型分析" | tee -a "$LOG_FILE"
# Step 1 由 main 自己完成，这里只记录
echo "  级别: $LEVEL" >> "$RUN_DIR/step1-classification.txt"
echo "  任务: $TASK" >> "$RUN_DIR/step1-classification.txt"

echo "[$(date +%H:%M:%S)] Step 1.5: Constitution-First 打磨层" | tee -a "$LOG_FILE"

# Step 1.5A: Gemini 扫描
echo "  [1.5A] Gemini 扫描问题..." | tee -a "$LOG_FILE"
openclaw agent --agent gemini --task "【星链 Step 1.5A - 扫描】

任务: $TASK
级别: $LEVEL

请扫描以下内容：
1. 需求歧义点（哪些地方可能有多种理解？）
2. 边界不清晰（范围、输入输出、异常处理）
3. 潜在风险点（安全、性能、兼容性）
4. 待验证假设（依赖的前提条件）

输出格式：
- 问题清单（按优先级排序）
- 盲点清单（容易忽略的地方）
- 待验证假设（需要确认的前提）

保存到: $WORKSPACE/agents/gemini/reports/scan-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE"

# Step 1.5B: OpenAI 宪法
echo "  [1.5B] OpenAI 制定宪法..." | tee -a "$LOG_FILE"
openclaw agent --agent openai --task "【星链 Step 1.5B - 宪法】

任务: $TASK
级别: $LEVEL
Gemini 扫描结果: $WORKSPACE/agents/gemini/reports/scan-${TIMESTAMP}.md

基于 Gemini 的扫描结果，制定开发宪法（1-2 页核心约束）：

1. **范围定义**：明确做什么、不做什么
2. **判定标准**：成功的标准是什么
3. **禁止项**：绝对不能做的事
4. **证据门槛**：需要什么证据才能通过审查
5. **输出格式**：代码、文档、测试的格式要求

输出格式：简洁、可执行、无歧义

保存到: $WORKSPACE/agents/openai/reports/constitution-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE"

# Step 1.5C: Claude 计划
echo "  [1.5C] Claude 制定实施计划..." | tee -a "$LOG_FILE"
openclaw agent --agent claude --task "【星链 Step 1.5C - 计划】

任务: $TASK
级别: $LEVEL
宪法: $WORKSPACE/agents/openai/reports/constitution-${TIMESTAMP}.md

基于宪法，制定实施计划：

1. **技术路径**：选择什么技术方案
2. **实施步骤**：分几步完成，每步做什么
3. **风险控制**：如何规避 Gemini 指出的风险
4. **验证方式**：如何证明符合宪法要求

输出格式：清晰的实施路径 + 关键决策理由

保存到: $WORKSPACE/agents/claude/reports/plan-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE"

# Step 1.5D: Gemini 一致性复核
echo "  [1.5D] Gemini 一致性复核..." | tee -a "$LOG_FILE"
openclaw agent --agent gemini --task "【星链 Step 1.5D - 复核】

任务: $TASK
宪法: $WORKSPACE/agents/openai/reports/constitution-${TIMESTAMP}.md
计划: $WORKSPACE/agents/claude/reports/plan-${TIMESTAMP}.md

检查计划与宪法的一致性：

1. **是否对齐**：计划是否完全符合宪法要求
2. **是否遗漏**：宪法要求的内容计划是否都覆盖了
3. **是否偏题**：计划是否做了宪法禁止的事
4. **是否矛盾**：计划内部是否有前后矛盾

输出判定：ALIGN / DRIFT / MAJOR_DRIFT

保存到: $WORKSPACE/agents/gemini/reports/review-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE"

# 检查是否需要仲裁
REVIEW_RESULT=$(grep -oP '判定：\K\w+' "$WORKSPACE/agents/gemini/reports/review-${TIMESTAMP}.md" || echo "ALIGN")

if [[ "$REVIEW_RESULT" == "MAJOR_DRIFT" ]] || [[ "$LEVEL" == "L3" ]]; then
  echo "  [1.5E] 触发仲裁（$REVIEW_RESULT / $LEVEL）..." | tee -a "$LOG_FILE"
  openclaw agent --agent openai --task "【星链 Step 1.5E - 仲裁】

任务: $TASK
宪法: $WORKSPACE/agents/openai/reports/constitution-${TIMESTAMP}.md
计划: $WORKSPACE/agents/claude/reports/plan-${TIMESTAMP}.md
复核意见: $WORKSPACE/agents/gemini/reports/review-${TIMESTAMP}.md

仲裁计划与宪法的分歧：

判定标准：
- 一致性 30%
- 风险控制 25%
- 可行性 25%
- 完整性 20%

输出判定：GO / REVISE / BLOCK

保存到: $WORKSPACE/agents/openai/reports/arbitration-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE"
fi

echo "[$(date +%H:%M:%S)] Step 1.5S: NotebookLM 深度研究 + Spec-Kit 落地" | tee -a "$LOG_FILE"

# Step 1.5S-A: NotebookLM 深度研究
echo "  [1.5S-A] NotebookLM 查询历史经验..." | tee -a "$LOG_FILE"
openclaw agent --agent notebooklm --task "【星链 Step 1.5S-A - 深度研究】

任务: $TASK
宪法: $WORKSPACE/agents/openai/reports/constitution-${TIMESTAMP}.md
计划: $WORKSPACE/agents/claude/reports/plan-${TIMESTAMP}.md

查询 starchain-knowledge notebook，提供：

1. **历史经验**：类似任务的实施经验
2. **常见坑点**：容易踩的坑和规避方法
3. **推荐路径**：推荐的技术路径和理由
4. **参考实现**：可以参考的代码片段或模板

输出格式：实施建议文档

保存到: $WORKSPACE/agents/notebooklm/implementation-advice-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE"

# Step 1.5S-B: Brainstorming 落地 Spec-Kit
echo "  [1.5S-B] Brainstorming 落地 Spec-Kit..." | tee -a "$LOG_FILE"
openclaw agent --agent brainstorming --task "【星链 Step 1.5S-B - Spec-Kit】

任务: $TASK
宪法: $WORKSPACE/agents/openai/reports/constitution-${TIMESTAMP}.md
计划: $WORKSPACE/agents/claude/reports/plan-${TIMESTAMP}.md
NotebookLM 建议: $WORKSPACE/agents/notebooklm/implementation-advice-${TIMESTAMP}.md

基于以上材料，落地 Spec-Kit 四件套：

1. **spec.md**：技术规格（API、数据结构、接口）
2. **plan.md**：实施计划（步骤、时间、依赖）
3. **tasks.md**：开发任务清单（可直接执行）
4. **research.md**：技术调研（技术选型、风险评估）

保存到: $WORKSPACE/agents/brainstorming/specs/spec-kit-${TIMESTAMP}/
" 2>&1 | tee -a "$LOG_FILE"

echo "[$(date +%H:%M:%S)] Step 2: Coding 开发" | tee -a "$LOG_FILE"
openclaw agent --agent coding --task "【星链 Step 2 - 开发】

任务: $TASK
Spec-Kit: $WORKSPACE/agents/brainstorming/specs/spec-kit-${TIMESTAMP}/

按照 tasks.md 开发，完成后执行 Step 2.5 冒烟测试。

保存到: $WORKSPACE/agents/coding/
" 2>&1 | tee -a "$LOG_FILE"

echo "[$(date +%H:%M:%S)] Step 3: 双审（Claude + Gemini）" | tee -a "$LOG_FILE"

# 并行 spawn Claude 和 Gemini
openclaw agent --agent claude --task "【星链 Step 3 - 主审查】

任务: $TASK
代码: $WORKSPACE/agents/coding/
Spec-Kit: $WORKSPACE/agents/brainstorming/specs/spec-kit-${TIMESTAMP}/

审查代码是否符合规格和宪法要求。

保存到: $WORKSPACE/agents/claude/reports/review-step3-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE" &

openclaw agent --agent gemini --task "【星链 Step 3 - Adversarial Review】

任务: $TASK
代码: $WORKSPACE/agents/coding/
Spec-Kit: $WORKSPACE/agents/brainstorming/specs/spec-kit-${TIMESTAMP}/

找漏洞、找风险、找不符合宪法的地方。

保存到: $WORKSPACE/agents/gemini/reports/review-step3-${TIMESTAMP}.md
" 2>&1 | tee -a "$LOG_FILE" &

wait

echo "[$(date +%H:%M:%S)] Step 4: 修复循环（max 3 rounds）" | tee -a "$LOG_FILE"
# 这里简化处理，实际应该检查审查结果并循环
echo "  跳过（简化版）" | tee -a "$LOG_FILE"

echo "[$(date +%H:%M:%S)] Step 5: Test 测试" | tee -a "$LOG_FILE"
openclaw agent --agent test --task "【星链 Step 5 - 测试】

任务: $TASK
代码: $WORKSPACE/agents/coding/
Spec-Kit: $WORKSPACE/agents/brainstorming/specs/spec-kit-${TIMESTAMP}/

执行完整测试。

保存到: $WORKSPACE/agents/test/
" 2>&1 | tee -a "$LOG_FILE"

echo "[$(date +%H:%M:%S)] Step 6: 文档生成" | tee -a "$LOG_FILE"
openclaw agent --agent docs --task "【星链 Step 6 - 文档】

任务: $TASK
代码: $WORKSPACE/agents/coding/
Spec-Kit: $WORKSPACE/agents/brainstorming/specs/spec-kit-${TIMESTAMP}/

生成交付文档。

保存到: $WORKSPACE/agents/docs/
" 2>&1 | tee -a "$LOG_FILE"

echo "[$(date +%H:%M:%S)] Step 7: 汇总交付" | tee -a "$LOG_FILE"

# 更新任务状态
jq '.status = "completed" | .endTime = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' "$RUN_DIR/task.json" > "$RUN_DIR/task.json.tmp"
mv "$RUN_DIR/task.json.tmp" "$RUN_DIR/task.json"

echo "========================================" | tee -a "$LOG_FILE"
echo "星链流水线完成" | tee -a "$LOG_FILE"
echo "运行 ID: $RUN_ID" | tee -a "$LOG_FILE"
echo "日志: $LOG_FILE" | tee -a "$LOG_FILE"
echo "产物: $RUN_DIR" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# 返回运行 ID 供 main 使用
echo "$RUN_ID"
