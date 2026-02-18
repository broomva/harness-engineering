# Actuators

Define the actions agents are allowed to perform to move the system toward setpoints.

## Actuation Surface

- Code edits
- Test and build execution
- Script/template updates
- CI workflow adjustments
- Documentation updates

## Safety Boundaries

- Protected branches/rules:
- Restricted commands:
- Approval-required actions:

## Action Catalog

| Action | Preconditions | Postconditions | Rollback |
|---|---|---|---|
| patch code | tests defined | checks green | revert commit |
| update harness docs | doc owner review | docs aligned | restore prior doc |
| tune CI workflow | CI dry run | stable runtime | revert workflow |
