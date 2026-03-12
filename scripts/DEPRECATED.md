# DEPRECATED

这些 launcher 脚本已废弃，不再使用。

## 原因

从 v2.8 开始，星链和星鉴流水线改回 Main 编排 + isolated session 模式。

**新的使用方式**：
- 星链：告诉 Main "用星链实现 XXX，L2"
- 星鉴：告诉 Main "用星鉴评估 XXX，D 级"

Main 会自动 spawn isolated session 执行流水线，主私聊不占线。

## 废弃的脚本

- `starchain-launcher.sh` - 已废弃，使用 Main 编排代替
- `stareval-launcher.sh` - 已废弃，使用 Main 编排代替

## 为什么改回 Main 编排？

**收益评估**：
- 使用频率：每天频繁使用
- 用户体验：手动运行脚本 vs 告诉 Main
- 维护成本：SKILL.md + launcher.sh vs 只维护 SKILL.md
- Main 职责：保持顶层编排中心的角色

**结论**：收益明显大于成本，改回 Main 编排。

---

保留这些脚本仅作为历史参考。
