# Wizard CLI

This skill ships a Typer-based CLI wizard:

- `scripts/harness_wizard.py`

Use it as the primary interface for bootstrapping and evolving repositories.

## Quick Start

```bash
python3 scripts/harness_wizard.py init <repo-path> --profile control
python3 scripts/harness_wizard.py status <repo-path>
python3 scripts/harness_wizard.py audit <repo-path>
```

## Commands

### `init`

Initialize a repository with harness and control-system structures.

```bash
python3 scripts/harness_wizard.py init <repo-path> --profile baseline
python3 scripts/harness_wizard.py init <repo-path> --profile control
python3 scripts/harness_wizard.py init <repo-path> --profile full
python3 scripts/harness_wizard.py init <repo-path> --profile full --force
```

Profiles:

- `baseline`: AGENTS/PLANS/docs/Makefile/scripts/CI core harness.
- `control`: baseline + control primitives (`docs/control/*`, metrics yaml).
- `full`: control + entropy controls (`entropy_check.sh`, nightly workflow).

### `audit`

Run baseline harness audit wrapper:

```bash
python3 scripts/harness_wizard.py audit <repo-path>
```

### `status`

Show baseline and primitive coverage:

```bash
python3 scripts/harness_wizard.py status <repo-path>
```

### `primitive list`

List all available control primitives and associated files:

```bash
python3 scripts/harness_wizard.py primitive list
```

### `primitive add`

Add selected primitives to an existing repo incrementally:

```bash
python3 scripts/harness_wizard.py primitive add setpoint sensors --repo <repo-path>
python3 scripts/harness_wizard.py primitive add entropy --repo <repo-path>
```
