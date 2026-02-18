# Sensors

List the signals used to evaluate whether the system is on target.

## Required Sensors

- CI results (lint/typecheck/test/smoke)
- Structured runtime events
- Trace spans for long workflows
- Regression eval outcomes
- Review outcomes (requested changes, approval lag)

## Signal Contracts

| Sensor | Required Fields | Sampling | Storage |
|---|---|---|---|
| harness events | trace_id, run_id, status, duration_ms | always | logs/traces |
| CI checks | check_name, status, duration_ms | always | CI provider |
| eval runs | task_id, pass_fail, score, runtime | per run | eval store |

## Sensor Gaps

- Missing signals:
- Noisy/unreliable signals:
- Planned remediation:
