# AGENTS.md

> Replace placeholder text and keep this file compact, command-first, and operational.

## Project Overview

- Project: `<project-name>`
- Primary runtime(s): `<runtime>`
- Main entrypoint(s): `<entrypoints>`

## Harness Commands

Run from repository root:

| Goal | Command |
|---|---|
| Fast sanity check | `make smoke` |
| Static checks | `make check` |
| Full test suite | `make test` |
| CI-equivalent local run | `make ci` |

## Constraints And Guardrails

- Prefer deterministic scripts over interactive/manual steps.
- Keep command names stable (`smoke`, `check`, `test`, `ci`).
- Update docs and scripts in the same change when workflow behavior changes.
- Avoid side effects outside the repo unless explicitly required.

## Architecture Boundaries

- Parse and validate external data at boundaries.
- Keep internal data models typed and normalized.
- Keep each module focused on one responsibility.
- Document boundary ownership in `docs/ARCHITECTURE.md`.

## Observability Expectations

- Include `trace_id` and `run_id` in long-running workflow logs.
- Emit structured event names for major transitions (start, step, success, failure).
- Keep event fields stable for querying and alerting.
- Maintain field definitions in `docs/OBSERVABILITY.md`.

## Execution Plans

- For tasks expected to exceed ~30 minutes, create/update `PLANS.md` before coding.
- Track scope, constraints, milestones, and verification steps.
- Update status checkpoints during execution and after major decisions.

## Static Analysis And Quality Gates

- Run `make check` before `make test`.
- Run `make ci` before pushing large refactors.
- Treat lint/type failures as blocking.

## Entropy Management

- Remove stale scripts/docs quickly.
- Keep templates and real workflows in sync.
- Run periodic harness audits:
  - `scripts/audit_harness.sh .`
