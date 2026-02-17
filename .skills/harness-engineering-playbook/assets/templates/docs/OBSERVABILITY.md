# Observability

## Goal

Make agent and harness workflows diagnosable without reproducing locally.

## Required Event Fields

- `timestamp`
- `level`
- `event_name`
- `trace_id`
- `run_id`
- `step_id`
- `component`
- `status`
- `duration_ms`

## Event Taxonomy

- `harness.start`
- `harness.step.start`
- `harness.step.finish`
- `harness.step.fail`
- `harness.check.pass`
- `harness.check.fail`

## Logging Rules

- Emit structured logs for machine parsing.
- Keep field names stable over time.
- Include enough context to replay failures.
- Redact secrets and personally identifiable values.

## Metrics

- Smoke-check duration
- Check failure rate (lint/type/test)
- Retry count per run
- Time-to-first-actionable-error

## Alerting

- Alert on repeated harness failures in CI.
- Alert on missing observability fields in critical events.
- Alert on regression in smoke-check runtime budget.
