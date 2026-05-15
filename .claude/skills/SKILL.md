---
name: xxf-framework-guardrails
description: Hard execution contract for AI coding agents. Deny-by-default for architecture/framework edits without explicit scope, approval, and verifiable quality gates.
---

# XXF AI Coding Guardrails (Hard Mode)

## 0. Purpose
- Prevent low-quality "揉代码" changes.
- Prevent architecture pollution and random refactors.
- Force minimal, verifiable, maintainable edits.

## 1. Default Policy (Deny By Default)
- If request is ambiguous, over-broad, or missing acceptance criteria: STOP and ask for clarification.
- If request touches framework/core architecture without explicit `XXF approved`: REFUSE implementation.
- If change cannot be verified (build/tests/checks unavailable): proceed only with minimal safe edit and explicitly mark unverified risk.

## 2. Mandatory Input Contract (Must Have Before Editing)
All items required:
1. Goal: one-sentence business/technical objective.
2. Scope: exact files/modules allowed to change.
3. Non-goals: what must NOT be changed.
4. Acceptance: observable pass criteria.
5. Constraints: compatibility/performance/security boundaries.

If any missing: do not edit code.

## 3. Boundary Rules
- Business logic stays in business layer.
- Framework layer only for reusable abstractions across multiple features.
- No one-off feature branches inside shared core.
- No hidden side effects, global mutable coupling, or magic behavior.

## 4. Forbidden Behaviors (Zero Tolerance)
- Vibe coding / speculative refactor.
- Mixing functional change with unrelated cleanup.
- Large rewrites when small patch is possible.
- Silent fallback that hides errors.
- Adding TODO/FIXME as substitute for completion.
- API/toolchain/dependency upgrades unless explicitly requested.

## 5. Code Generation Quality Rules (AI-Facing)
- Prefer existing patterns in repo over invented style.
- Keep patch minimal: smallest diff that solves the issue.
- New abstraction requires proof: at least 2 concrete call sites or explicit future extension requirement from user.
- Public API change requires compatibility note and migration note.
- Error handling must be explicit, typed when possible, and logged at boundary.
- Concurrency changes must state isolation/synchronization model.

## 6. Required Output Contract (Every Response)
Agent must output in this order:
1. Boundary judgment: business vs framework.
2. Risk level: Low/Medium/High with one-line reason.
3. Plan: minimal steps.
4. Patch summary: exact files changed.
5. Verification: commands run + result.
6. Residual risks: what is not proven.

If refused, output:
- Refusal reason
- Missing prerequisites
- Smallest acceptable next input from user

## 7. Verification Gates (Before Completion)
Must attempt, in order:
1. Compile/build relevant target.
2. Run affected tests (or nearest subset).
3. Static checks/format checks if configured.
4. Behavior sanity check for modified path.

If any gate cannot run, explicitly report:
- which gate
- why not run
- risk introduced

## 8. Change Size Guardrails
- Soft limit: <= 3 files for bugfix, <= 8 files for feature unless user asks broader refactor.
- If exceeding limit: require explicit justification section before editing.
- Avoid cross-module edits unless required by compile/runtime contract.

## 9. Architecture Edit Protocol (Strict)
If touching `Sources/*` shared framework internals and behavior contracts:
- Require explicit `XXF approved` in user request.
- Require compatibility statement:
  - API compatibility
  - data/protocol compatibility
  - rollback strategy
- Without these: refuse.

## 10. Anti-Rotten-Code Checklist
Reject or rework if any is true:
- Duplicate logic introduced where shared utility already exists.
- Function/class does more than one reason to change.
- Naming does not reflect domain intent.
- Branch complexity increases without tests.
- New code path lacks failure handling.
- Hard-coded business constants leak into shared modules.

## 11. Performance/Safety Baseline
For performance-sensitive or concurrency-sensitive edits, include:
- Before/after expectation (latency/memory/contention)
- Failure mode analysis
- Fallback/rollback note

## 12. One-Line Enforcement
- No clarity, no boundary, no approval, no verification: no code change.
