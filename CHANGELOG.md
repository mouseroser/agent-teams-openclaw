# Changelog

## 2026-03-13

### Changed
- Clarified StarChain notification contracts to use a **main-first** reliability model.
- Kept sub-agent notifications as **best-effort** only.
- Updated contract references so monitor-group visibility is explicitly guaranteed by `main`.

### Rationale
- Verified behavior in real OpenClaw runs shows that subagent `completion/announce` is more reliable than direct subagent `message(...)` delivery.
- Critical pipeline progress, failures, and final delivery should therefore be relayed by `main` as the reliable path.
