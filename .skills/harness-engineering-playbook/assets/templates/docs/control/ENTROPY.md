# Entropy Management

Define recurring cleanup actions that prevent harness drift.

## Drift Sources

- Stale docs after workflow changes
- Dead scripts no longer called by CI
- Flaky tests ignored over time
- Inconsistent logging field names

## Entropy Controls

- Weekly harness audit
- Monthly docs/script alignment review
- Periodic flaky-test triage
- Architectural boundary checks after refactors

## Required Commands

- `scripts/harness/entropy_check.sh`
- `scripts/audit_harness.sh .`

## Ownership

- Primary owner:
- Backup owner:
- Review cadence:
