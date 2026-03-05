# 成本预算和超支告警

## 目的

为每个任务设定 token 预算，实时追踪消耗，超支时提前告警和降级，避免成本失控。

---

## 预算定义

### 基于等级的预算

| 等级 | Token 预算 | 预期时长 | 典型场景 |
|------|-----------|---------|---------|
| **L1** | 50,000 | 10-20 分钟 | 简单修复、配置调整、文档更新 |
| **L2** | 200,000 | 30-60 分钟 | 标准功能开发、中等复杂度重构 |
| **L3** | 500,000 | 1-3 小时 | 大型功能、架构重构、跨模块变更 |

### 预算分配（参考比例）

| 步骤 | L1 | L2 | L3 | 说明 |
|------|----|----|----|----|
| Step 1 | 5k | 10k | 20k | 分级 + 类型分析 |
| Step 1.5 | - | 40k | 100k | Spec-Kit + 打磨层（L1 跳过） |
| Step 2 | 15k | 50k | 120k | 开发 |
| Step 2.5 | 2k | 5k | 10k | 冒烟测试 |
| Step 3 | 8k | 30k | 80k | 交叉审查 |
| Step 4 | 10k | 40k | 100k | 修复循环（预留） |
| Step 5 | 5k | 15k | 40k | 全量测试 |
| Step 5.5 | - | - | 30k | Epoch 回退（预留） |
| Step 6 | - | 10k | 20k | 文档生成（L1 跳过） |
| **缓冲** | 5k | 20k | 50k | 应对超支 |

---

## 成本追踪

### 追踪记录格式

保存到 `workspace/cost-tracking.json`：

```json
{
  "task_id": "task-20260305-001",
  "requirement": "添加用户登录 API",
  "level": "L2",
  "budget": 200000,
  "consumed": 85000,
  "remaining": 115000,
  "utilization": 0.425,
  "status": "in_progress",
  "breakdown": {
    "step_1": {
      "tokens": 8500,
      "budget": 10000,
      "utilization": 0.85,
      "model": "anthropic/claude-opus-4-6",
      "thinking": "high"
    },
    "step_1.5": {
      "tokens": 35000,
      "budget": 40000,
      "utilization": 0.875,
      "sub_steps": {
        "notebooklm": 5000,
        "gemini": 12000,
        "review": 8000,
        "brainstorming": 10000
      }
    },
    "step_2": {
      "tokens": 42000,
      "budget": 50000,
      "utilization": 0.84,
      "model": "openai-codex/gpt-5.2",
      "thinking": "medium"
    }
  },
  "alerts": [
    {
      "timestamp": 1772716800000,
      "level": "P2",
      "message": "Step 1.5 消耗接近预算（87.5%）"
    }
  ],
  "started_at": 1772716000000,
  "updated_at": 1772716800000
}
```

---

## 超支告警

### 告警阈值

| 利用率 | 告警级别 | 处理方式 |
|--------|---------|---------|
| < 80% | 正常 | 无告警 |
| 80% ~ 100% | P2 | 推送监控群，提醒注意 |
| 100% ~ 120% | P1 | 推送监控群 + 晨星，启动降级 |
| > 120% | P0 | 推送监控群 + 晨星，强制降级或 HALT |

### 告警消息格式

```json
{
  "alert_level": "P1",
  "task_id": "task-20260305-001",
  "requirement": "添加用户登录 API",
  "level": "L2",
  "budget": 200000,
  "consumed": 210000,
  "utilization": 1.05,
  "message": "成本超支 5%，已启动降级措施",
  "actions_taken": [
    "后续步骤降级为 thinking=low",
    "跳过可选步骤（Step 6 文档生成）"
  ],
  "estimated_final_cost": 230000
}
```

---

## 降级策略

### 超支 80%（P2 告警）

**措施**：
1. 推送 P2 告警到监控群
2. 提醒 main agent 注意成本
3. 继续正常执行，不降级

**消息**：
```
ℹ️ P2 告警
任务：添加用户登录 API (L2)
成本利用率：85%（170k / 200k）
状态：接近预算，请注意后续步骤成本
```

---

### 超支 100%（P1 告警 + 降级）

**措施**：
1. 推送 P1 告警到监控群 + 晨星
2. 启动降级措施：
   - 后续步骤 thinking 降级为 "low"
   - 跳过可选步骤（Step 6 文档生成）
   - Step 4 修复循环限制为 2 轮（原 3 轮）
3. 继续执行，监控成本

**消息**：
```
⚠️ P1 告警
任务：添加用户登录 API (L2)
成本超支：5%（210k / 200k）
降级措施：
- 后续步骤 thinking=low
- 跳过 Step 6 文档生成
- Step 4 限制 2 轮
预计最终成本：230k
```

---

### 超支 120%（P0 告警 + 强制降级）

**措施**：
1. 推送 P0 告警到监控群 + 晨星
2. 强制降级措施：
   - 所有后续步骤 thinking="low"
   - 跳过所有可选步骤（Step 1.5 研究、Step 6 文档）
   - Step 4 修复循环限制为 1 轮
   - 考虑提前交付（degraded 状态）
3. 如果仍超支 → HALT

**消息**：
```
🚨 P0 告警
任务：添加用户登录 API (L2)
成本严重超支：25%（250k / 200k）
强制降级措施：
- 所有步骤 thinking=low
- 跳过所有可选步骤
- Step 4 限制 1 轮
- 考虑提前交付（degraded）
预计最终成本：280k
建议：人工评估是否继续
```

---

## 实施流程

### main agent 成本追踪

```python
# 伪代码
class CostTracker:
    def __init__(self, task_id, level):
        self.task_id = task_id
        self.level = level
        self.budget = self.get_budget(level)
        self.consumed = 0
        self.breakdown = {}
        self.alerts = []
    
    def get_budget(self, level):
        """获取预算"""
        budgets = {"L1": 50000, "L2": 200000, "L3": 500000}
        return budgets[level]
    
    def record_step(self, step_name, tokens, model, thinking):
        """记录步骤消耗"""
        self.consumed += tokens
        self.breakdown[step_name] = {
            "tokens": tokens,
            "model": model,
            "thinking": thinking
        }
        
        # 检查超支
        self.check_overspend()
        
        # 保存到文件
        self.save()
    
    def check_overspend(self):
        """检查超支"""
        utilization = self.consumed / self.budget
        
        if utilization >= 1.20:
            # P0 告警 + 强制降级
            self.alert_p0()
            self.apply_aggressive_degradation()
        elif utilization >= 1.00:
            # P1 告警 + 降级
            self.alert_p1()
            self.apply_degradation()
        elif utilization >= 0.80:
            # P2 告警
            self.alert_p2()
    
    def apply_degradation(self):
        """应用降级措施"""
        return {
            "thinking": "low",
            "skip_optional": ["step_6"],
            "step_4_max_rounds": 2
        }
    
    def apply_aggressive_degradation(self):
        """应用强制降级措施"""
        return {
            "thinking": "low",
            "skip_optional": ["step_1.5_research", "step_6"],
            "step_4_max_rounds": 1,
            "consider_early_delivery": True
        }
    
    def save(self):
        """保存到文件"""
        data = {
            "task_id": self.task_id,
            "level": self.level,
            "budget": self.budget,
            "consumed": self.consumed,
            "remaining": self.budget - self.consumed,
            "utilization": self.consumed / self.budget,
            "breakdown": self.breakdown,
            "alerts": self.alerts
        }
        save_json("workspace/cost-tracking.json", data)
```

### 使用示例

```python
# Step 1 开始时初始化
tracker = CostTracker(task_id="task-20260305-001", level="L2")

# 每个步骤完成后记录
tracker.record_step(
    step_name="step_1",
    tokens=8500,
    model="anthropic/claude-opus-4-6",
    thinking="high"
)

# 检查是否需要降级
degradation = tracker.get_degradation_config()
if degradation:
    # 应用降级配置到后续步骤
    apply_degradation(degradation)
```

---

## 成本预测

### 预测模型

基于历史数据预测最终成本：

```python
def predict_final_cost(current_step, consumed, level):
    """预测最终成本"""
    # 加载历史数据
    history = load_historical_costs(level)
    
    # 计算当前步骤的平均进度
    avg_progress = history[current_step]["avg_progress"]
    
    # 预测最终成本
    predicted = consumed / avg_progress
    
    return predicted

# 示例
current_step = "step_3"
consumed = 85000
predicted = predict_final_cost(current_step, consumed, "L2")
# 输出：预计最终成本 195000 tokens
```

### 预测告警

如果预测成本超过预算 80%，提前告警：

```json
{
  "alert_level": "P2",
  "message": "预测成本接近预算",
  "current_step": "step_3",
  "consumed": 85000,
  "predicted_final": 195000,
  "budget": 200000,
  "predicted_utilization": 0.975,
  "recommendation": "考虑在后续步骤降低 thinking level"
}
```

---

## 集成到流水线

### main agent AGENTS.md 更新

在 Step 1 初始化部分添加：

```markdown
### Step 1：分级 + 类型分析 + 成本初始化
1. 量化分级（L1/L2/L3）
2. 类型分析（A/B/C）
3. **成本追踪初始化**（参考 `references/cost-budget.md`）:
   - 根据等级设定预算：L1=50k / L2=200k / L3=500k
   - 初始化 workspace/cost-tracking.json
   - 记录 Step 1 消耗
4. 推送分配单到监控群
```

在每个步骤完成后添加：

```markdown
### 步骤完成后
1. 记录 token 消耗到 cost-tracking.json
2. 检查超支情况：
   - 80% → P2 告警
   - 100% → P1 告警 + 降级
   - 120% → P0 告警 + 强制降级
3. 应用降级配置（如需要）
```

---

## 监控和统计

### 成本统计报告

每月生成成本统计报告：

```json
{
  "month": "2026-03",
  "total_tasks": 50,
  "total_tokens": 8500000,
  "by_level": {
    "L1": {
      "count": 20,
      "avg_tokens": 35000,
      "budget_utilization": 0.70,
      "overspend_count": 2
    },
    "L2": {
      "count": 25,
      "avg_tokens": 180000,
      "budget_utilization": 0.90,
      "overspend_count": 5
    },
    "L3": {
      "count": 5,
      "avg_tokens": 450000,
      "budget_utilization": 0.90,
      "overspend_count": 1
    }
  },
  "overspend_analysis": {
    "total_overspend": 8,
    "reasons": [
      {"reason": "Step 4 修复循环超过 2 轮", "count": 4},
      {"reason": "Step 5.5 Epoch 回退", "count": 3},
      {"reason": "需求复杂度低估", "count": 1}
    ]
  },
  "cost_optimization": {
    "degradation_triggered": 8,
    "tokens_saved": 120000,
    "savings_rate": 0.014
  }
}
```

### 预算校准

基于历史数据定期校准预算：

1. **每月回顾**：
   - 分析超支案例
   - 调整预算分配比例
   - 优化降级策略

2. **季度校准**：
   - 评估预算合理性
   - 考虑调整 L1/L2/L3 预算
   - 更新预测模型

---

## 注意事项

1. **预算是指导性的**：不是硬性限制，超支时优先保证质量
2. **降级是渐进的**：从 thinking level 开始，逐步跳过可选步骤
3. **人工优先**：严重超支时建议人工评估是否继续
4. **持续优化**：基于历史数据不断优化预算和降级策略
5. **透明可追溯**：所有成本记录和降级决策必须可追溯
6. **质量优先**：降级不能影响核心功能的正确性
