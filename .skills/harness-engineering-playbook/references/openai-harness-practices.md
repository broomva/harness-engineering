# OpenAI Harness Practices Mapping

This file maps each practice from OpenAI's Harness Engineering guidance to concrete repo artifacts.

## Sources

- Harness Engineering: https://openai.com/index/harness-engineering/
- Using `PLANS.md` for multi-hour tasks: https://cookbook.openai.com/articles/plan-driven-workflow
- Data-shape boundary design reference: https://matklad.github.io/2023/08/17/types-are-parse-don-t-validate.html
- Boundary-first architecture reference: https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html

## Practice Matrix

| Practice | What To Implement | Required Artifacts | Verification |
|---|---|---|---|
| 1. Make easy to do hard thing | Single-command wrappers for high-value tasks. | `Makefile.harness`, `scripts/harness/*.sh` | `make smoke`, `make check`, and `make ci` run without manual prep. |
| 2. Communicate actionable constraints with compact docs | Command-first guardrails and operational constraints. | `AGENTS.md` | Agent can execute common tasks without guessing undocumented behavior. |
| 3. Structure codebase with strict boundaries and flow | Clear boundaries, typed contracts, boundary parsing. | `docs/ARCHITECTURE.md` | Data transformations happen at edges; internals are simpler and traceable. |
| 4. Build observability in from day 1 | Structured events/logs and correlation IDs. | `docs/OBSERVABILITY.md` | Every critical transition has traceable identifiers and stable fields. |
| 5. Optimize for agent flow, not human flow | Durable, resumable planning context. | `PLANS.md` | Long tasks remain reproducible after interruptions or handoffs. |
| 6. Bring your own harness | Repo-local deterministic workflows (no hidden UI/manual steps). | `Makefile.harness`, `scripts/harness/` | Same commands work in local and CI environments. |
| 7. Prototype in natural language first | Prose-first logic drafts before code. | `PLANS.md` sections for behavior/testing intent | First implementation pass has fewer reworks and edge-case misses. |
| 8. Invest in static analysis and linting | Fast-fail checks before expensive runs. | `Makefile.harness`, CI workflow | Lint/typecheck break builds early; test time is spent on validated code. |
| 9. Manage entropy | Scheduled audits and drift control. | `scripts/audit_harness.sh`, CI integration | Harness docs/scripts stay aligned with repo behavior over time. |

## Non-Negotiables

1. Keep command entrypoints stable (`make smoke`, `make check`, `make ci`).
2. Keep docs compact and executable, not narrative-heavy.
3. Keep scripts deterministic and machine-readable.
4. Keep architecture boundaries explicit and reviewed during refactors.
5. Keep observability fields stable to support aggregation and replay.

## Wizard Entry Point

Use `scripts/harness_wizard.py` as the stable orchestration layer for bootstrap, primitive upgrades, and auditing.
