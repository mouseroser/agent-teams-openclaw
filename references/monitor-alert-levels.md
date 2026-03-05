# monitor-bot 告警分级规范

## 目的

明确 monitor-bot 的告警分级标准，避免告警冗余或遗漏关键异常，提升告警信噪比。

---

## 告警分级体系

### P0：立即处理（Critical）

**特征**：影响流水线核心功能，需要立即人工介入

**响应时间**：< 5 分钟

**推送渠道**：
- 监控群 (-5131273722)
- 晨星私聊 (1099011886)
- （可选）电话告警

**告警场景**：

| 场景 | 触发条件 | 示例 |
|------|---------|------|
| 不可恢复异常 | 认证失败、配置错误、权限不足 | `auth_missing`, `config error` |
| 流水线 HALT | Epoch > 3 或任何步骤超时 30 分钟 | Epoch 回退 3 次仍失败 |
| 成本严重超支 | 利用率 > 120% | L2 任务消耗 250k tokens |
| 关键步骤失败 | Step 2.5 冒烟自修复 2 次仍失败 | 编译错误无法修复 |

**告警格式**：
```
🚨 P0 告警 - 立即处理

任务：添加用户登录 API (L2)
问题：认证失败 (auth_missing)
影响：流水线 BLOCKED，无法继续
位置：Step 1.5 珊瑚查询
错误：NotebookLM CLI 认证文件缺失

修复建议：
1. 检查 ~/.notebooklm/storage_state.json
2. 重新运行 notebooklm login
3. 重启流水线

时间：2026-03-05 21:35:00
任务ID：task-20260305-001
```

---

### P1：1小时内处理（High）

**特征**：影响流水线效率或质量，需要尽快处理

**响应时间**：< 1 小时

**推送渠道**：
- 监控群 (-5131273722)
- 晨星私聊 (1099011886)

**告警场景**：

| 场景 | 触发条件 | 示例 |
|------|---------|------|
| Step 4 R3 失败 | 修复循环 3 轮仍 NEEDS_FIX | 复杂逻辑错误 |
| 成本超支 | 利用率 100% ~ 120% | L2 任务消耗 210k tokens |
| Epoch 低置信度 | 置信度 < 0.5 | 历史相似案例 < 3 |
| 可恢复异常重试失败 | 重试 3 次仍失败 | LLM 超时 3 次 |
| ReEntry 预算耗尽 | ReEntry > ReEntry_MAX | TF 返回 Step 3 超过 2 次 |

**告警格式**：
```
⚠️ P1 告警 - 1小时内处理

任务：添加用户登录 API (L2)
问题：Step 4 修复循环 R3 失败
影响：即将进入 Step 5.5 Epoch 回退
当前状态：NEEDS_FIX（3 个 major issues）

问题详情：
1. 逻辑错误：登录验证逻辑不完整
2. 性能问题：数据库查询未优化
3. 安全问题：密码未加密存储

建议：人工评估是否需要介入

时间：2026-03-05 21:35:00
任务ID：task-20260305-001
```

---

### P2：24小时内处理（Medium）

**特征**：不影响核心功能，但需要关注

**响应时间**：< 24 小时

**推送渠道**：
- 监控群 (-5131273722)

**告警场景**：

| 场景 | 触发条件 | 示例 |
|------|---------|------|
| 降级异常 | NotebookLM/Gemini 不可用 | 珊瑚查询失败 |
| 成本接近预算 | 利用率 80% ~ 100% | L2 任务消耗 170k tokens |
| 性能劣化 | 响应时间 +10% ~ +20% | 轻微性能下降 |
| 分级边界 | 分数在阈值 ±10 | 分数 95（L1/L2 边界） |
| PASS_WITH_NOTES 降级 | minor fix diff > G2 | 小修改超过 20 行 |
| TF diff > G3 | 测试修复超过 30 行 | 需要返回 Step 3 |

**告警格式**：
```
ℹ️ P2 告警 - 24小时内处理

任务：添加用户登录 API (L2)
问题：珊瑚(NotebookLM)不可用
影响：Step 1.5 跳过历史知识查询，质量略降
降级措施：已应用，继续执行

详情：
- 错误：nlm-gateway.sh auth_missing
- 降级：跳过珊瑚查询，依赖模型权重
- 预期影响：Step 1.5 质量降低 10-15%

建议：检查 NotebookLM 认证配置

时间：2026-03-05 21:35:00
任务ID：task-20260305-001
```

---

### P3：信息通知（Info）

**特征**：正常流程事件，仅供记录

**响应时间**：无需响应

**推送渠道**：
- 监控群 (-5131273722)（可选，避免刷屏）

**告警场景**：

| 场景 | 触发条件 | 示例 |
|------|---------|------|
| 流程开始 | 任务启动 | Step 1 分级完成 |
| 流程完成 | 任务交付 | Step 7 交付成功 |
| 快照创建 | S1/S2/S3 创建 | S1 快照已创建 |
| L1 升级 | L1 自动升级为 L2 | 复杂度超出预期 |

**告警格式**：
```
✅ 任务完成

任务：添加用户登录 API (L2)
状态：正常交付
等级：L2
耗时：45 分钟
成本：185k tokens（92.5% 预算）
快照：S1, S2, S3

时间：2026-03-05 21:35:00
任务ID：task-20260305-001
```

---

## 异常聚合

### 聚合规则

**目的**：避免告警风暴，相同类型异常合并推送

**聚合窗口**：5 分钟

**聚合逻辑**：
```python
def aggregate_alerts(alerts, window_ms=300000):
    """聚合相同类型的告警"""
    aggregated = {}
    
    for alert in alerts:
        key = (alert["level"], alert["type"])
        
        if key not in aggregated:
            aggregated[key] = {
                "level": alert["level"],
                "type": alert["type"],
                "count": 0,
                "first_time": alert["timestamp"],
                "last_time": alert["timestamp"],
                "examples": []
            }
        
        agg = aggregated[key]
        agg["count"] += 1
        agg["last_time"] = alert["timestamp"]
        
        # 保留前 3 个示例
        if len(agg["examples"]) < 3:
            agg["examples"].append(alert)
    
    return list(aggregated.values())
```

### 聚合告警格式

```
⚠️ P1 告警（聚合）

类型：LLM 超时
数量：5 次
时间范围：21:30:00 - 21:35:00

受影响任务：
1. task-20260305-001 (gemini spawn)
2. task-20260305-002 (coding spawn)
3. task-20260305-003 (review spawn)

建议：检查 API 服务状态

首次：2026-03-05 21:30:00
最近：2026-03-05 21:35:00
```

---

## 告警抑制

### 抑制规则

**目的**：避免重复告警，降低噪音

**抑制场景**：

| 场景 | 抑制规则 | 示例 |
|------|---------|------|
| 相同任务相同问题 | 5 分钟内只推送 1 次 | 同一任务的 LLM 超时 |
| 已知问题 | 人工标记后抑制 | NotebookLM 维护期间 |
| 低优先级告警 | P3 告警默认抑制 | 流程开始/完成通知 |

**抑制记录**：
```json
{
  "suppressed_alerts": [
    {
      "alert_id": "alert-001",
      "type": "LLM_TIMEOUT",
      "task_id": "task-20260305-001",
      "suppressed_at": 1772716800000,
      "reason": "5分钟内重复告警",
      "next_alert_after": 1772717100000
    }
  ]
}
```

---

## 告警路由

### 路由规则

| 告警级别 | 监控群 | 晨星私聊 | 电话（可选） |
|---------|-------|---------|------------|
| P0 | ✅ | ✅ | ✅ |
| P1 | ✅ | ✅ | ❌ |
| P2 | ✅ | ❌ | ❌ |
| P3 | 可选 | ❌ | ❌ |

### 路由实现

```python
def route_alert(alert):
    """路由告警到不同渠道"""
    level = alert["level"]
    
    # 监控群（所有级别）
    if level in ["P0", "P1", "P2"]:
        send_to_monitor_group(alert)
    
    # 晨星私聊（P0/P1）
    if level in ["P0", "P1"]:
        send_to_chenxing(alert)
    
    # 电话告警（P0，可选）
    if level == "P0" and alert.get("critical", False):
        trigger_phone_alert(alert)
```

---

## 集成到流水线

### monitor-bot AGENTS.md 更新

```markdown
## 告警分级规范

参考：`references/monitor-alert-levels.md`

### P0（立即处理）
- 不可恢复异常、HALT、成本严重超支、关键步骤失败
- 推送：监控群 + 晨星私聊 + 电话（可选）

### P1（1小时内）
- Step 4 R3 失败、成本超支、Epoch 低置信度、重试失败
- 推送：监控群 + 晨星私聊

### P2（24小时内）
- 降级异常、成本接近预算、性能劣化、分级边界
- 推送：监控群

### P3（信息通知）
- 流程开始/完成、快照创建、L1 升级
- 推送：监控群（可选）

### 异常聚合
- 5 分钟窗口内相同类型异常合并推送
- 保留前 3 个示例

### 告警抑制
- 5 分钟内相同任务相同问题只推送 1 次
- 已知问题人工标记后抑制
```

---

## 监控和统计

### 告警统计报告

每月生成告警统计报告：

```json
{
  "month": "2026-03",
  "total_alerts": 150,
  "by_level": {
    "P0": {"count": 5, "avg_response_time_min": 3},
    "P1": {"count": 20, "avg_response_time_min": 35},
    "P2": {"count": 80, "avg_response_time_min": 180},
    "P3": {"count": 45, "suppressed": 30}
  },
  "by_type": {
    "LLM_TIMEOUT": 25,
    "AUTH_FAILED": 5,
    "COST_OVERSPEND": 15,
    "STEP_FAILED": 10,
    "DEGRADATION": 30
  },
  "aggregation_stats": {
    "total_aggregated": 40,
    "alerts_saved": 120,
    "reduction_rate": 0.44
  },
  "suppression_stats": {
    "total_suppressed": 30,
    "by_reason": {
      "duplicate": 20,
      "known_issue": 10
    }
  }
}
```

### 持续优化

1. **每月回顾**：
   - 分析告警分布
   - 识别高频告警
   - 优化聚合和抑制规则

2. **季度校准**：
   - 评估告警级别合理性
   - 调整路由规则
   - 更新告警模板

---

## 注意事项

1. **宁可多告警，不可漏告警**：不确定时提升告警级别
2. **聚合避免刷屏**：相同类型异常合并推送
3. **抑制降低噪音**：重复告警抑制，但不能漏掉新问题
4. **路由精准**：P0/P1 必须通知晨星，P2 只推监控群
5. **持续优化**：基于反馈不断优化告警规则
6. **可追溯**：所有告警必须记录，支持事后分析
