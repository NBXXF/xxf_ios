---
name: xxf-framework-guardrails
description: Zero-tolerance guardrails to prevent arbitrary framework refactors. Default deny unless architecture justification and XXF approval are explicit.
---

# XXF Framework Collaboration Guardrails (Zero-Tolerance)

## Core Intent
- Goal: do not allow arbitrary framework changes.
- Default mode: deny-by-default for framework refactor requests.

## Absolute Rules
- No random modification.
- No vibe coding.
- No business logic in framework core.
- No architecture refactor without explicit XXF approval.

## Default Decision Policy (Mandatory)
- If request touches framework core and lacks clear architecture justification: refuse implementation.
- If business/framework boundary is unclear: stop and ask for clarification.
- If requirement is business-specific: route to business-layer polymorphism/inheritance/decorator/composition.

## Required Preconditions Before Any Framework Edit
1. Clear boundary statement: why framework layer is the correct layer.
2. Existing abstraction review: what extension points already exist.
3. Compatibility statement: API/behavior/backward-compat impact.
4. Minimality statement: why this is the smallest safe change.
5. Approval statement: explicit "XXF approved" for architecture-affecting changes.

If any precondition is missing: do not edit code.

## Forbidden Behaviors
- Broad rewrites for local feature needs.
- Mixing unrelated cleanup with functional change.
- Public API expansion without necessity and compatibility proof.
- Hard-coded scenario branches tied to one business line.
- Upgrading API versions without explicit request and compatibility validation.
- Upgrading Swift language/compiler version without explicit request (especially Swift 6.x).
- Upgrading third-party dependencies by default or "while we are here".

## Version Upgrade Red Lines (Mandatory)
1. API Compatibility First
- Do not proactively migrate to new API signatures/protocols.
- Keep old API behavior and call patterns stable unless user explicitly asks for migration.
- Any unavoidable API change must include compatibility strategy (adapter/fallback/deprecation path).

2. Swift Toolchain Stability First
- Do not change Swift tools version / compiler target by default.
- Do not introduce Swift 6.x-only constraints/features unless explicitly required and approved.
- Prefer the currently working compiler baseline to avoid hidden compile/runtime regressions.

3. Third-Party Dependency Stability First
- Do not bump dependency versions unless explicitly requested or required for blocking security/build issues.
- If upgrade is necessary, scope to minimal version delta and assess transitive impact.
- No opportunistic dependency refresh during unrelated tasks.

## Execution Discipline (Think First, Then Change)
Before any edit, complete all items below:
1. Study current behavior and boundaries in the existing code.
2. Verify backward compatibility risk (API, compile, runtime, dependency graph).
3. Provide minimal-impact plan and why alternatives are riskier.
4. Only then implement the smallest safe change.

If analysis is insufficient: stop editing and continue investigation first.

## Collaboration Response Contract
- Start with boundary judgment.
- If preconditions fail: explicitly refuse and explain why.
- Only after preconditions pass: provide minimal plan, then edit.

## One-Line Enforcement
- Better no change than reckless change; justify first, then implement; no architecture change without approval.
- No arbitrary version upgrades, no compatibility breakage, no excessive changes; understand deeply before editing.
