# Epoch 决策置信度评分

## 目的

基于历史数据为 Epoch 回滚决策提供置信度评分，避免重复失败的回滚策略，提升 Epoch 成功率。

---

## 置信度评分模型

### 评分公式

```
置信度 = 历史成功率 × 相似度权重

其中：
- 历史成功率 = 相似场景成功次数 / 相似场景总次数
- 相似度权重 = 0.5 ~ 1.0（基于失败日志关键词匹配度）
```

### 相似度计算

#### 失败模式关键词

| 失败模式 | 关键词 | 推荐回滚策略 |
|---------|-------|------------|
| 架构变更过大 | `architecture`, `refactor`, `restructure` | rollback_to_S1 |
| 逻辑错误 | `logic error`, `incorrect result`, `wrong output` | rollback_to_S2 |
| 性能劣化 | `performance`, `timeout`, `slow`, `memory` | rollback_to_S2 |
| 依赖冲突 | `dependency`, `import error`, `module not found` | rollback_to_S1 |
| 测试覆盖不足 | `test failed`, `assertion error`, `edge case` | continue（补充测试） |

#### 相似度权重规则

```python
def calculate_similarity(current_failure, historical_failure):
    """计算失败日志相似度"""
    current_keywords = extract_keywords(current_failure)
    historical_keywords = extract_keywords(historical_failure)
    
    # 关键词交集
    common_keywords = set(current_keywords) & set(historical_keywords)
    
    # Jaccard 相似度
    similarity = len(common_keywords) / len(set(current_keywords) | set(historical_keywords))
    
    # 转换为权重（0.5 ~ 1.0）
    weight = 0.5 + similarity * 0.5
    
    return weight
```

---

## epoch-history.json 扩展格式

### 完整记录格式

```json
{
  "epochs": [
    {
      "timestamp": 1772691000000,
      "requirement": "添加用户登录 API",
      "failure_log": "Step 5 测试失败：架构变更导致依赖冲突",
      "failure_keywords": ["architecture", "dependency", "conflict"],
      "decision": "rollback_to_S1",
      "confidence": 0.75,
      "similar_cases": 8,
      "success_rate": 0.625,
      "reason": "历史数据显示架构变更回滚到 S1 成功率较高",
      "result": "success",
      "duration_ms": 180000,
      "final_snapshot": "S3"
    },
    {
      "timestamp": 1772694600000,
      "requirement": "优化数据库查询",
      "failure_log": "Step 5 测试失败：性能劣化，响应时间增加 50%",
      "failure_keywords": ["performance", "slow", "timeout"],
      "decision": "rollback_to_S2",
      "confidence": 0.85,
      "similar_cases": 12,
      "success_rate": 0.833,
      "reason": "性能问题通常在 Step 3 后引入，回滚到 S2 成功率高",
      "result": "success",
      "duration_ms": 120000,
      "final_snapshot": "S3"
    },
    {
      "timestamp": 1772698200000,
      "requirement": "修复边界条件 Bug",
      "failure_log": "Step 5 测试失败：边界条件未覆盖",
      "failure_keywords": ["test failed", "edge case", "boundary"],
      "decision": "continue",
      "confidence": 0.60,
      "similar_cases": 5,
      "success_rate": 0.60,
      "reason": "测试覆盖不足，补充测试用例即可",
      "result": "success",
      "duration_ms": 90000,
      "final_snapshot": "S3"
    }
  ],
  "stats": {
    "total_epochs": 25,
    "by_decision": {
      "rollback_to_S1": {"count": 10, "success": 8, "success_rate": 0.80},
      "rollback_to_S2": {"count": 12, "success": 10, "success_rate": 0.833},
      "continue": {"count": 3, "success": 2, "success_rate": 0.667}
    },
    "by_failure_pattern": {
      "architecture": {"count": 8, "best_decision": "rollback_to_S1", "success_rate": 0.875},
      "performance": {"count": 12, "best_decision": "rollback_to_S2", "success_rate": 0.833},
      "test_coverage": {"count": 5, "best_decision": "continue", "success_rate": 0.60}
    }
  }
}
```

---

## 实施流程

### Step 5.5: brainstorming 执行置信度评分

```python
# 伪代码
def analyze_epoch_decision(current_failure_log):
    # 1. 提取当前失败关键词
    current_keywords = extract_keywords(current_failure_log)
    
    # 2. 加载历史数据
    history = load_json("workspace/epoch-history.json")
    
    # 3. 查询相似场景
    similar_cases = []
    for epoch in history["epochs"]:
        similarity = calculate_similarity(
            current_keywords,
            epoch["failure_keywords"]
        )
        if similarity > 0.5:  # 相似度阈值
            similar_cases.append({
           "epoch": epoch,
                "similarity": similarity
            })
    
    # 4. 按决策类型统计
    decision_stats = {}
    for case in similar_cases:
        decision = case["epoch"]["decision"]
        if decision not in decision_stats:
            decision_stats[decision] = {"total": 0, "success": 0}
        decision_stats[decision]["total"] += 1
        if case["epoch"]["result"] == "success":
            decision_stats[decision]["success"] += 1
    
    # 5. 计算每个决策的置信度
    confidences = {}
    for decision, stats in decision_stats.items():
        success_rate = stats[/ stats["total"]
        avg_similarity = sum(c["similarity"] for c in similar_cases 
                            if c["epoch"]["decision"] == decision) / stats["total"]
        confidence = success_rate * avg_similarity
        confidences[decision] = {
            "confidence": confidence,
            "success_rate": success_rate,
            "similar_cases": stats["total"]
        }
    
    # 6. 推荐决策（置信度最高）
    best_decision = max(confidences.items(), key=lambda x: x[1]["confidence"])
    
    return {
        "recommended_decision": best_decision[0],
        "confidence": best_decision[1]["confidence"],
        "similar_cases": best_decision[1]["similar_cases"],
        "success_rate": best_decision[1]["success_rate"],
        "all_options": confidences
    }
```

### 决策输出格式

```json
{
  "analysis": {
    "current_failure": "Step 5 测试失败：架构变更导致依赖冲突",
    "failure_keywords": ["architecture", "dependency", "conflict"],
    "similar_cases_found": 8
  },
  "recommended_decision": "rollback_to_S1",
  "confidence": 0.75,
  "success_rate": 0.625,
  "reason": "历史数据显示架构变更回滚到 S62.5%，相似度 0.8",
  "all_options": {
    "rollback_to_S1": {
      "confidence": 0.75,
      "success_rate": 0.625,
      "similar_cases": 8
    },
    "rollback_to_S2": {
      "confidence": 0.45,
      "success_rate": 0.50,
      "similar_cases": 4
    },
    "continue": {
      "confidence": 0.30,
      "success_rate": 0.40,
      "similar_cases": 3
    }
  },
  "warning": null
}
```

---

## 低置信度处理

### 置信度阈值

| 置信度 | 级别 | 处理方式 |
|--------|------|---------|
| ≥ 0.7 | 高置信度 | 直接采用推荐决策 |
| 0.5 ~ 0.7 | 中置信度 | 采用推荐决策 + 推送 P2 告警 |
| < 0.5 | 低置信度 | 推送 P1 告警 + 建议人工介入 |

### 低置信度告警

```json
{
  "alert_level": "P1",
  "message": "Epoch 决策置信度低（0.45），建议人工介入",
  "details": {
    "current_failure": "Step 5 测试失败：未知错误模式",
    "recommended_decision": "rollback_to_S2",
    "confidence": 0.45,
    "similar_cases": 2,
    "reason": "历史相似案例较少，决策不确定性高"
  },
  "fallback_strategy": "采用保守策略：rollback_to_S1"
}
```

### 保守策略

当置信度 < 0.5 时，采用保守策略：

1. **优先回滚到 S1**（最安全）
2. 推送 P1 告警到监控群 + 通知晨星
3. 在交付报告中标注 "EPOCH_LOW_CONFIDENCE"
4. 记录到历史，用于后续模型优化

---

## 冷启动问题

### 初始阶段（历史数据 < 10 条）

**问题**：历史数据不足，无法计算可靠的置信度

**解决方案**：

1. **使用默认策略**：
   ```json
   {
     "default_strategies": {
       "architecture": "rollback_to_S1",
       "performance": "rollback_to_S2",
       "logic_error": "rollback_to_S2",
       "test_coverage": "continue"
     }
   }
   ```

2. **标注冷启动**：
   ```json
   {
     "confidence": 0.50,
     "reason": "历史数据不足（< 10 条），使用默认策略",
     "cold_start": true
   }
   ```

3. **快速积累数据**：
   - 每次 Epoch 都记录详细信息
   - 10 条数据后启用置信度评分
   - 20 条数据后模型趋于稳定

---

## 集成到流水线

### Step 5.5 流程更新

```markdown
### Step 5.5：Epoch 回退（max 3 Es）
main 编排：
1. （可选）spawn 织梦(gemini, thinking="high") 产出诊断 memo
2. **Epoch 智能决策（置信度评分）**：
   - main 读取 workspace/epoch-history.json
   - spawn brainstorming(opus/high) 分析根因 + 计算置信度
     - 输入：当前失败日志 + 诊断 memo + 历史数据
     - 输出：推荐决策 + 置信度 + 成功率 + 理由
   - **置信度处理**：
     - ≥ 0.7：直接采用推荐决策
     - 0.5 ~ 0.7：采用推荐 + 推送 P2 告警
     - < 0.5：推送 P1 告警 + 建议人工介入 + 保守策略（rollback_to_S1）
3. 回滚代码到选定快照
4. 重新走 Step 2 → 2.5 → 3 → 5
5. **记录 Epoch 结果**：
   - 更新 workspace/epoch-history.json
   - 记录：决策、置信度、快照、结果、耗时、失败关键词
6. Epoch > 3 → HALT
```

---

## 监控和优化

### 置信度准确率监控

每月生成置信度准确率报告：

```json
{
  "month": "2026-03",
  "chs": 15,
  "by_confidence_level": {
    "high (≥0.7)": {
      "count": 8,
      "success": 7,
      "accuracy": 0.875
    },
    "medium (0.5-0.7)": {
      "count": 5,
      "success": 3,
      "accuracy": 0.60
    },
    "low (<0.5)": {
      "count": 2,
      "success": 1,
      "accuracy": 0.50
    }
  },
  "insights": [
    "高置信度决策准确率 87.5%，模型可靠",
    "中置信度决策准确率 60%，需要更多历史数据",
    "低置信度决策建议人工介入"
  ]
}
```

### 持续优化

1. **每月校准**：
   - 调整相似度阈值
   - 优化关键词提取算法
   - 更新失败模式分类

2. **季度回顾**：
   - 评估置信度模型整体效果
   - 识别新的失败模式
 推荐策略

3. **年度重构**：
   - 考虑引入机器学习模型
   - 基于更多特征（代码复杂度、团队经验等）

---

## 注意事项

1. **冷启动处理**：历史数据不足时使用默认策略
2. **低置信度告警**：置信度 < 0.5 时推送 P1 告警
3. **保守原则**：不确定时优先回滚到 S1
4. **持续学习**：每次 Epoch 都记录详细信息
5. **透明可解释**：决策必须可追溯、可解释
6. **人工优先**：低置信度时建议人工介入
