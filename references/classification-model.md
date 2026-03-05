# Step 1 分级量化模型

## 目的

通过量化指标替代主观判断，提升 L1/L2/L3 分级准确率，避免资源浪费和质量风险。

---

## 复杂度评分模型

### 评分公式

```
复杂度分数 = 
  文件数 × 10 +
  代码行数 × 0.1 +
  依赖深度 × 20 +
  风险等级 × 50
```

### 指标说明

#### 1. 文件数（Files Count）
- **定义**：需要修改或新增的文件数量
- **权重**：10
- **测量方法**：
  ```bash
  # 从需求中提取文件列表
  # 或从 git diff 统计
  git diff --name-only | wc -l
  ```

#### 2. 代码行数（Lines of Code）
- **定义**：预计修改或新增的代码行数
- **权重**：0.1
- **测量方法**：
  ```bash
  # 从 git diff 统计
  git diff --stat | tail -1 | awk '{print $4+$6}'
  ```
- **估算规则**（无 diff 时）：
  - 简单修复：50-100 行
  - 标准功能：200-500 行
  - 大型功能：1000+ 行

#### 3. 依赖深度（Dependency Depth）
- **定义**：涉及的模块依赖层级深度
- **权重**：20
- **测量方法**：
  - 单模块修改：深度 = 1
  - 跨模块修改（2-3 个模块）：深度 = 2
  - 架构级修改（4+ 个模块）：深度 = 3
  - 外部依赖变更：深度 = 4

#### 4. 风险等级（Risk Level）
- **定义**：变更的风险程度
- **权重**：50
- **风险评估表**：

| 风险等级 | 分数 | 场景 |
|---------|------|------|
| 低风险 | 1 | 文档更新、配置调整、日志优化 |
| 中风险 | 2 | 新增功能、重构单模块、Bug 修复 |
| 高风险 | 3 | 架构变更、核心逻辑修改、数据库迁移 |
| 极高风险 | 4 | 安全修复、性能优化、跨系统集成 |

---

## 分级阈值

### 阈值定义

| 等级 | 分数范围 | 特征 | 流程 |
|------|---------|------|------|
| **L1** | < 100 | 简单修复、配置调整、文档更新 | 快速通道（跳过 Step 1.5/6） |
| **L2** | 100 ~ 299 | 标准功能开发、中等复杂度重构 | 标准流程（含 Step 1.5） |
| **L3** | ≥ 300 | 大型功能、架构重构、跨模块变更 | 完整流程（含 Step 1.5 + 深度审查） |

### 分级示例

#### 示例 1：文档更新（L1）
```
文件数: 2 (README.md, CHANGELOG.md)
代码行数: 50
依赖深度: 1 (单模块)
风险等级: 1 (低风险)

分数 = 2×10 + 50×0.1 + 1×20 + 1×50 = 95
等级 = L1
```

#### 示例 2：新增 API 端点（L2）
```
文件数: 5 (controller, service, model, test, doc)
代码行数: 300
依赖深度: 2 (跨 2 个模块)
风险等级: 2 (中风险)

分数 = 5×10 + 300×0.1 + 2×20 + 2×50 = 220
等级 = L2
```

#### 示例 3：架构重构（L3）
```
文件数: 15
代码行数: 1200
依赖深度: 3 (跨 4+ 个模块)
风险等级: 3 (高风险)

分数 = 15×10 + 1200×0.1 + 3×20 + 3×50 = 420
等级 = L3
```

---

## 实施流程

### Step 1: main agent 执行分级

```python
# 伪代码
def classify_task(requirement):
    # 1. 提取指标
    files_count = extract_files_count(requirement)
    lines_of_code = estimate_lines_of_code(requirement)
    dependency_depth = analyze_dependency_depth(requirement)
    risk_level = assess_risk_level(requirement)
    
    # 2. 计算分数
    score = (
        files_count * 10 +
        lines_of_code * 0.1 +
        dependency_depth * 20 +
        risk_level * 50
    )
    
    # 3. 判定等级
    if score < 100:
        level = "L1"
    elif score < 300:
        level = "L2"
    else:
        level = "L3"
    
    # 4. 记录到历史
    record_classification({
        "timestamp": now(),
        "requirement": requirement,
        "metrics": {
            "files_count": files_count,
            "lines_of_code": lines_of_code,
            "dependency_depth": dependency_depth,
            "risk_level": risk_level
        },
        "score": score,
        "level": level
    })
    
    return level, score
```

### 历史记录格式

保存到 `workspace/classification-history.json`：

```json
{
  "classifications": [
    {
      "timestamp": 1772716800000,
      "requirement": "添加用户登录 API",
      "metrics": {
        "files_count": 5,
        "lines_of_code": 300,
        "dependency_depth": 2,
        "risk_level": 2
      },
      "score": 220,
      "level": "L2",
      "actual_level": "L2",
      "accurate": true
    },
    {
      "timestamp": 1772720400000,
      "requirement": "更新 README 文档",
      "metrics": {
        "files_count": 1,
        "lines_of_code": 30,
        "dependency_depth": 1,
        "risk_level": 1
      },
      "score": 83,
      "level": "L1",
      "actual_level": "L1",
      "accurate": true
    }
  ],
  "stats": {
    "total": 50,
    "accurate": 42,
    "accuracy_rate": 0.84,
    "by_level": {
      "L1": {"total": 20, "accurate": 18},
      "L2": {"total": 25, "accurate": 21},
      "L3": {"total": 5, "accurate": 3}
    }
  }
}
```

---

## 模型校准

### 定期回顾（每月）

1. **收集反馈**：
   - Step 7 交付时，review agent 评估实际等级
   - 对比预测等级和实际等级
   - 记录误判案例

2. **分析误判**：
   - L1 误判为 L2/L3 → 浪费资源
   - L2/L3 误判为 L1 → 质量风险
   - 识别误判模式

3. **调整权重**：
   - 基于误判案例调整权重
   - 例如：发现依赖深度影响更大 → 提高权重到 25
   - 更新评分公式

4. **更新阈值**：
   - 基于历史数据分布调整阈值
   - 例如：L1/L2 边界从 100 调整到 120

### 校准示例

```json
{
  "calibration_history": [
    {
      "date": "2026-03-01",
      "formula": "files×10 + lines×0.1 + depth×20 + risk×50",
      "thresholds": {"L1": 100, "L2": 300},
      "accuracy": 0.84
    },
    {
      "date": "2026-04-01",
      "formula": "files×10 + lines×0.1 + depth×25 + risk×50",
      "thresholds": {"L1": 120, "L2": 320},
      "accuracy": 0.89,
      "changes": "提高依赖深度权重，调整阈值"
    }
  ]
}
```

---

## 边界情况处理

### 1. 分数接近阈值
- **场景**：分数在阈值 ±10 范围内（如 95-105）
- **处理**：
  - 推送 P2 告警："分级接近边界，建议人工确认"
  - 默认采用保守策略（向上升级）
  - 在交付报告中标注 "CLASSIFICATION_BORDERLINE"

### 2. 指标缺失
- **场景**：需求描述不清晰，无法提取指标
- **处理**：
  - 使用默认估算值（中等复杂度）
  - 推送 P2 告警："需求信息不足，使用默认分级"
  - 在 Step 1.5 补充需求澄清

### 3. 人工覆盖
- **场景**：晨星明确指定等级
- **处理**：
  - 尊重人工判断，使用指定等级
  - 记录到历史，标注 "MANUAL_OVERRIDE"
  - 用于后续模型校准

---

## 集成到流水线

### main agent AGENTS.md 更新

在 Step 1 部分添加：

```markdown
### Step 1：分级 + 类型分析（量化模型）
1. **量化分级**（参考 `references/classification-model.md`）:
   - 提取指标：文件数、代码行数、依赖深度、风险等级
   - 计算分数：files×10 + lines×0.1 + depth×20 + risk×50
   - 判定等级：
     - L1: < 100（快速通道）
     - L2: 100-299（标准流程）
     - L3: ≥ 300（完整流程）
   - 记录到 workspace/classification-history.json
2. **类型分析**：A（业务/架构）/ B（算法/性能）/ C（混合）
3. **边界处理**：
   - 分数在阈值 ±10 → 推送 P2 告警，保守升级
   - 指标缺失 → 使用默认估算，推送 P2 告警
   - 人工覆盖 → 尊重指定等级，标注 MANUAL_OVERRIDE
4. 推送分配单到监控群
```

---

## 监控和优化

### 准确率监控

每周生成准确率报告：

```json
{
  "week": "2026-03-01 to 2026-03-07",
  "total_tasks": 12,
  "accurate": 10,
  "accuracy_rate": 0.833,
  "misclassifications": [
    {
      "requirement": "添加缓存层",
      "predicted": "L2",
      "actual": "L3",
      "reason": "低估了依赖深度"
    },
    {
      "requirement": "修复拼写错误",
      "predicted": "L1",
      "actual": "L1",
      "reason": "准确"
    }
  ]
}
```

### 持续优化

1. **每月校准**：调整权重和阈值
2. **季度回顾**：评估模型整体效果
3. **年度重构**：考虑引入机器学习模型

---

## 注意事项

1. **保守原则**：不确定时向上升级，避免质量风险
2. **人工优先**：晨星明确指定等级时，尊重人工判断
3. **持续学习**：基于历史数据不断优化模型
4. **透明可解释**：分级结果必须可追溯、可解释
5. **边界告警**：接近阈值时推送告警，建议人工确认
