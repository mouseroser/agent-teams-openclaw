# StarChain v2.9 Flowchart

## Route Overview

```text
User request
   ↓
Step 1 main classification
   ├─ L1 → main direct / single-agent path
   ├─ L2 → StarChain Lite
   └─ L3 → StarChain Full
```

---

## StarChain Lite

```text
Step 1    🧭 main classify
   ↓
Step 1A   💡 founder-office-hours (optional when direction/scope is unclear)
   ↓
Step 1B   🗺️ autoplan-lite
   ↓
Step 2    🛠️ coding
   ↓
Step 3    🚦 review-gate
   ↓
Step 4    🧪 test / 🌐 qa-browser-check
   ↓
Step 5    📝 docs (as needed)
   ↓
Step 6    📦 main synthesis / delivery
   ↓
Step 7    📣 main reliable notification
   ↓
Step 8    🔁 release-retro (optional)
```

### Lite upgrade conditions

Upgrade Lite → Full when any of these are true:
- cross-module architecture emerges
- security / permissions / data migration appears
- research becomes the bottleneck
- plan does not converge
- `autoplan-lite` cannot stabilize the task
- 晨星 explicitly asks for full chain

---

## StarChain Full

```text
Step 1    🧭 main classify
   ↓
Step 1A   💡 founder-office-hours (default for L3)
   ↓
Step 1.5  🧱 Constitution-First
          ├─ 🔍 gemini scan
          ├─ 📚 notebooklm history / templates / pitfalls
          ├─ 📏 openai constitution
          ├─ 🧠 claude implementation plan
          ├─ ✅ gemini consistency review
          └─ ⚖️ openai / claude arbitration (as needed)
   ↓
Step 1.5S 📐 brainstorming Spec-Kit
          ├─ spec.md
          ├─ plan.md
          ├─ research.md
          ├─ tasks.md
          └─ analyze
   ↓
Step 2    🛠️ coding
   ↓
Step 3    🚦 review-gate
   ↓
Step 4    🧪 test / 🌐 qa-browser-check
   ↓
Step 5    📝 docs
   ↓
Step 6    📦 main synthesis / delivery
   ↓
Step 7    📣 main reliable notification
   ↓
Step 8    🔁 release-retro (optional)
```

---

## Quality Gate Logic

```text
coding done
   ↓
review-gate
   ├─ Pass → go to test / QA
   ├─ Pass with follow-ups → go forward with explicit follow-ups
   ├─ Needs fixes before QA → return to coding
   └─ Blocked → stop and notify
```

---

## QA Selection Logic

```text
After review-gate
   ├─ code / logic heavy → test
   ├─ UI / workflow / browser-visible → qa-browser-check
   └─ both → test first, qa-browser-check second
```

---

## Retro Trigger Logic

Run `release-retro` only when there is real learning value:
- L2/L3 delivery with meaningful complexity
- repeated failure patterns
- new checklist / memory / skill candidate
- painful but educational run
