# Stability

Track whether the development loop remains stable under normal and disturbed conditions.

## Stability Indicators

- Check pass consistency over time
- Low variance in cycle time
- Bounded retry counts
- Controlled regression rate

## Disturbance Scenarios

| Scenario | Expected Behavior | Recovery Target |
|---|---|---|
| dependency upgrade | temporary check failures | recover within 1 day |
| major feature branch | higher variance | recover within sprint |
| infra outage | degraded CI signal | recover when infra restored |

## Stabilization Playbook

- Reconfirm setpoints.
- Reduce surface area of active change.
- Enforce stricter checks temporarily.
- Run entropy cleanup.
