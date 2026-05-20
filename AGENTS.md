## XXF Coding Workflow

For normal coding tasks in this project, do not wait for the user to explicitly ask for tests, review, or release-risk assessment.

Before implementing a generic bugfix, feature change, refactor, or regression fix, first read:

- `./skills/xxf-aaa-delivery-loop/SKILL.md`

Then load any additional relevant skills:

- Matching XXF module skills under `./skills/xxf-*/SKILL.md`
- Engineering constraints when relevant:
  - `./skills/xxf-aaa-coding-style/SKILL.md`
  - `./skills/xxf-aaa-coding-arch/SKILL.md`
  - `./skills/xxf-aaa-class-declaration-guidelines/SKILL.md`
  - `./skills/xxf-aaa-test-strategy/SKILL.md`
  - `./skills/xxf-aaa-unit-test-writer/SKILL.md`
  - `./skills/xxf-aaa-auto-test-orchestrator/SKILL.md`
  - `./skills/xxf-aaa-code-reviewer/SKILL.md`
  - `./skills/xxf-aaa-risk-gate/SKILL.md`

Default expectation for ordinary coding work in this repo:

1. Make the smallest correct change.
2. Add or repair the minimum effective tests when the change needs regression protection.
3. Run the narrowest relevant verification.
4. Review the change when risk is non-trivial.
5. Surface a merge/release risk conclusion when residual risk remains.

Only skip one of these steps when it is clearly not applicable, or when blocked by sensitive credentials, signing, environment ambiguity, or explicit user direction.
