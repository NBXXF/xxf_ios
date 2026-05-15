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

## Design Patterns Reference (Use Deliberately, Not Mechanically)
- Creational: Singleton, Factory Method, Abstract Factory, Builder, Prototype, Object Pool.
- Structural: Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy.
- Behavioral: Strategy, Template Method, Observer, Command, State, Chain of Responsibility, Mediator, Memento, Visitor, Interpreter, Iterator.
- Concurrency/Resilience: Producer-Consumer, Read-Write Lock, Circuit Breaker, Retry, Bulkhead, Backpressure.
- Architecture-Level: Dependency Injection, Repository, Unit of Work, MVC, MVP, MVVM, Clean Architecture, Hexagonal (Ports and Adapters), Event-Driven, CQRS.

## Design Principles Checklist (Mandatory)
- SOLID: SRP, OCP, LSP, ISP, DIP.
- DRY, KISS, YAGNI.
- Separation of Concerns.
- Composition over Inheritance.
- Prefer immutability where practical.
- Explicit dependencies over hidden globals.
- Fail fast with clear errors.
- Backward compatibility by default.

## Design Paradigms Reference
- Imperative, Declarative.
- Procedural, Object-Oriented, Functional.
- Reactive, Event-Driven.
- Data-Oriented design (where performance-critical).
- Domain-Driven design (when domain complexity justifies it).

## Performance Metrics Baseline (Track Before/After Changes)
- Latency: p50, p90, p95, p99.
- Throughput: requests/tasks per second.
- Resource usage: CPU, memory, disk I/O, network I/O.
- Startup and initialization time.
- Render/interaction smoothness (UI frame drops, jank).
- Concurrency health: lock contention, queue depth, thread utilization.
- Reliability: crash rate, timeout rate, error rate, retry rate.
- Build performance: incremental build time, clean build time, test duration.

## Business vs Architecture Boundary (Mandatory Judgment)
- Business-layer concerns:
- Product rules, feature policy, copy/text, scenario-specific workflows, A/B logic, market/channel customization.
- Architecture/framework concerns:
- Reusable abstractions, cross-feature contracts, extension points, lifecycle management, shared infrastructure, cross-cutting reliability/performance mechanisms.
- Must stay in business layer:
- Scenario branches specific to one product line, one-off policy toggles, temporary campaign logic.
- Can enter framework layer only if all are true:
1. Reused by multiple business domains/features.
2. Stable abstraction with clear ownership and extension points.
3. Compatibility impact is explicitly analyzed and acceptable.
4. Minimal change scope is proven.
5. Explicit XXF approval exists for architecture-impacting edits.

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

## Architecture & Quality Governance (Leader-Level Mandatory Controls)

### 1) Architecture Decision Records (ADR)
- MUST create/update an ADR for any architecture-significant change.
- ADR MUST include: Context, Options, Tradeoffs, Decision, Compatibility Impact, Rollback Plan.
- FAIL condition: architecture change without ADR linkage.

### 2) Quality Gates (Release/Merge Blocking)
- MUST pass: build, unit tests, critical integration tests, static analysis, compatibility checks, and key performance baseline checks.
- MUST define hard thresholds for blocker metrics (for example: crash rate, timeout rate, p95 latency).
- FAIL condition: any blocking gate red status.

### 3) Compatibility Policy
- MUST NOT break stable API contracts, persisted data formats, network protocol compatibility, and migration paths by default.
- MUST define deprecation lifecycle: announce, dual-support window, removal date.
- FAIL condition: compatibility break without explicit approval and migration plan.

### 4) Change Risk Classification
- MUST classify each change as Low/Medium/High risk before implementation.
- High risk MUST require: dual review, rollback rehearsal, canary/gradual rollout, dedicated monitoring dashboard.
- FAIL condition: high-risk change merged without risk controls.

### 5) Observability First
- MUST instrument new or changed critical paths with logs, metrics, traces, and normalized error codes.
- MUST define alert conditions and ownership before rollout.
- FAIL condition: critical feature shipped without observability.

### 6) Performance Budget Governance
- MUST maintain budgets for startup time, memory, binary size, and key path latency/throughput.
- MUST compare before/after metrics for performance-sensitive changes.
- FAIL condition: budget regression without waiver and remediation plan.

### 7) Security & Privacy Baseline
- MUST enforce least privilege, secret handling policy, and sensitive-data masking.
- MUST perform dependency vulnerability checks and privacy impact assessment for user-data changes.
- FAIL condition: known critical security/privacy gap left unresolved.

### 8) Dependency Governance
- MUST define dependency intake criteria: maintenance health, license compliance, security posture, size impact.
- MUST pin versions and use controlled upgrade windows; emergency CVE patch flow must be documented.
- FAIL condition: unreviewed dependency add/upgrade.

### 9) Data/Schema Evolution Discipline
- MUST ensure schema and storage evolution is backward compatible and rollback-capable.
- MUST use staged migration patterns where needed (expand-migrate-contract, dual write/read fallback).
- FAIL condition: irreversible one-shot migration in normal release flow.

### 10) Incident & Reliability Operations
- MUST define severity model (Sev1/2/3), on-call ownership, incident response timeline, and RCA template.
- MUST track corrective actions to closure with owners and due dates.
- FAIL condition: repeated incident class without closed corrective actions.

### 11) Technical Debt Governance
- MUST maintain a debt register with impact, interest, owner, and target milestone.
- MUST allocate recurring capacity for debt repayment in each cycle.
- FAIL condition: debt continuously added with no repayment mechanism.

### 12) Team Operating Model
- MUST define RACI for architecture decisions, review authority, and acceptance authority.
- MUST standardize Definition of Ready, Definition of Done, and review checklists.
- FAIL condition: unclear decision ownership for architecture-impacting work.
