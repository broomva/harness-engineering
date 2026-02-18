# Harness Rollout Checklist

Use this staged checklist when integrating the harness into an existing repository with active development.

## Phase 0: Baseline

- [ ] Record current build/test/lint/typecheck entrypoints.
- [ ] Identify flaky checks and long-running hot spots.
- [ ] Confirm required environments (local, CI, containers, services).
- [ ] Create a starter entry in `PLANS.md` with scope and constraints.

## Phase 1: Bootstrap

- [ ] Run `python3 scripts/harness_wizard.py init <repo-path> --profile control`.
- [ ] Verify generated files are present.
- [ ] Customize template placeholders for project-specific commands.
- [ ] Confirm `Makefile` includes `Makefile.harness`.

## Phase 2: Practice Alignment

- [ ] Validate all nine practices against real workflows.
- [ ] Tighten `AGENTS.md` so high-probability tasks are one command each.
- [ ] Update `docs/ARCHITECTURE.md` with concrete module boundaries.
- [ ] Add observability identifiers in logs/events and document them.
- [ ] Make static analysis and type checks mandatory before full test runs.

## Phase 3: Automation + Entropy Control

- [ ] Enable `.github/workflows/harness.yml` (or equivalent CI job).
- [ ] Run `python3 scripts/harness_wizard.py audit <repo-path>` in CI.
- [ ] Add periodic review cadence for docs/scripts drift.
- [ ] Remove stale scripts and outdated docs to keep context clean.

## Exit Criteria

- [ ] New contributors can run harness commands without extra tribal knowledge.
- [ ] Agent runs are reproducible from clean checkout.
- [ ] Core workflows are observable and debuggable.
- [ ] Harness audit passes consistently.
