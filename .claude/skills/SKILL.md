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

## Collaboration Response Contract
- Start with boundary judgment.
- If preconditions fail: explicitly refuse and explain why.
- Only after preconditions pass: provide minimal plan, then edit.

## One-Line Enforcement
- 宁可不改，也不乱改；先论证，后动手；无批准，不改架构。
