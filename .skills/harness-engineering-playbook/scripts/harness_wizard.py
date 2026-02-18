#!/usr/bin/env python3
"""Harness Engineering wizard CLI.

This command-line tool bootstraps and upgrades repositories so they are
harness/control-system ready for autonomous agent workflows.
"""

from __future__ import annotations

import subprocess
from enum import Enum
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

import typer

app = typer.Typer(help="Harness engineering wizard for repository setup and control primitives.")
primitive_app = typer.Typer(help="Add or inspect control-system primitives.")
app.add_typer(primitive_app, name="primitive")


SCRIPT_DIR = Path(__file__).resolve().parent
SKILL_DIR = SCRIPT_DIR.parent
TEMPLATE_DIR = SKILL_DIR / "assets" / "templates"
BOOTSTRAP_SCRIPT = SCRIPT_DIR / "bootstrap_harness.sh"
AUDIT_SCRIPT = SCRIPT_DIR / "audit_harness.sh"

BASELINE_FILES: Tuple[str, ...] = (
    "AGENTS.md",
    "PLANS.md",
    "docs/ARCHITECTURE.md",
    "docs/OBSERVABILITY.md",
    "Makefile.harness",
    "scripts/audit_harness.sh",
    "scripts/harness/smoke.sh",
    "scripts/harness/test.sh",
    "scripts/harness/lint.sh",
    "scripts/harness/typecheck.sh",
    ".github/workflows/harness.yml",
)


class Primitive(str, Enum):
    loop = "loop"
    setpoint = "setpoint"
    sensors = "sensors"
    controller = "controller"
    actuators = "actuators"
    feedback = "feedback"
    stability = "stability"
    entropy = "entropy"


class Profile(str, Enum):
    baseline = "baseline"
    control = "control"
    full = "full"


PRIMITIVE_FILES: Dict[Primitive, Tuple[str, ...]] = {
    Primitive.loop: ("docs/control/CONTROL_SYSTEM.md",),
    Primitive.setpoint: (
        "docs/control/SETPOINTS.md",
        "evals/control-loop-metrics.yaml",
    ),
    Primitive.sensors: ("docs/control/SENSORS.md",),
    Primitive.controller: ("docs/control/CONTROLLER.md",),
    Primitive.actuators: ("docs/control/ACTUATORS.md",),
    Primitive.feedback: ("docs/control/FEEDBACK_LOOP.md",),
    Primitive.stability: ("docs/control/STABILITY.md",),
    Primitive.entropy: (
        "docs/control/ENTROPY.md",
        "scripts/harness/entropy_check.sh",
        ".github/workflows/nightly-harness-audit.yml",
    ),
}

CONTROL_PROFILE: Tuple[Primitive, ...] = (
    Primitive.loop,
    Primitive.setpoint,
    Primitive.sensors,
    Primitive.controller,
    Primitive.actuators,
    Primitive.feedback,
    Primitive.stability,
)

FULL_PROFILE: Tuple[Primitive, ...] = CONTROL_PROFILE + (Primitive.entropy,)


def _resolve_repo(repo_path: Path) -> Path:
    repo = repo_path.expanduser().resolve()
    if not repo.exists() or not repo.is_dir():
        typer.secho(f"error: repo path does not exist: {repo}", fg=typer.colors.RED, err=True)
        raise typer.Exit(code=2)
    return repo


def _run(script: Path, args: List[str]) -> None:
    if not script.exists():
        typer.secho(f"error: script not found: {script}", fg=typer.colors.RED, err=True)
        raise typer.Exit(code=2)
    command = [str(script), *args]
    result = subprocess.run(command, check=False)
    if result.returncode != 0:
        raise typer.Exit(code=result.returncode)


def _copy_template(relative_path: str, repo: Path, force: bool) -> str:
    source = TEMPLATE_DIR / relative_path
    target = repo / relative_path
    if not source.exists():
        typer.secho(f"error: missing template file: {source}", fg=typer.colors.RED, err=True)
        raise typer.Exit(code=2)

    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists() and not force:
        return "skip"

    target.write_bytes(source.read_bytes())
    if target.suffix == ".sh":
        target.chmod(0o755)
    return "write"


def _add_primitives(repo: Path, primitives: Iterable[Primitive], force: bool) -> None:
    for primitive in primitives:
        typer.secho(f"\n[{primitive.value}]")
        for relative_path in PRIMITIVE_FILES[primitive]:
            state = _copy_template(relative_path, repo, force)
            verb = "write" if state == "write" else "skip "
            typer.echo(f"  [{verb}] {relative_path}")


def _check_exists(repo: Path, relative_path: str) -> bool:
    return (repo / relative_path).exists()


def _primitive_status(repo: Path, primitive: Primitive) -> Tuple[int, int]:
    files = PRIMITIVE_FILES[primitive]
    present = sum(1 for rel in files if _check_exists(repo, rel))
    return present, len(files)


@app.command()
def init(
    repo_path: Path = typer.Argument(Path("."), help="Target repository path."),
    profile: Profile = typer.Option(
        Profile.control,
        "--profile",
        "-p",
        help="Setup profile: baseline, control, or full.",
    ),
    force: bool = typer.Option(False, "--force", help="Overwrite existing files."),
) -> None:
    """Initialize harness artifacts and optionally apply control primitives."""
    repo = _resolve_repo(repo_path)
    typer.secho(f"Initializing harness in {repo}", fg=typer.colors.CYAN)

    args = [str(repo)]
    if force:
        args.append("--force")
    _run(BOOTSTRAP_SCRIPT, args)

    if profile == Profile.baseline:
        return

    primitives = CONTROL_PROFILE if profile == Profile.control else FULL_PROFILE
    _add_primitives(repo, primitives, force=force)
    typer.secho("\nInitialization complete.", fg=typer.colors.GREEN)


@app.command()
def audit(
    repo_path: Path = typer.Argument(Path("."), help="Target repository path."),
) -> None:
    """Run baseline harness audit."""
    repo = _resolve_repo(repo_path)
    _run(AUDIT_SCRIPT, [str(repo)])


@app.command()
def status(
    repo_path: Path = typer.Argument(Path("."), help="Target repository path."),
) -> None:
    """Show harness and primitive coverage status."""
    repo = _resolve_repo(repo_path)
    typer.secho(f"Harness status for {repo}", fg=typer.colors.CYAN)
    typer.echo()

    baseline_present = sum(1 for rel in BASELINE_FILES if _check_exists(repo, rel))
    baseline_total = len(BASELINE_FILES)
    typer.echo(f"baseline: {baseline_present}/{baseline_total}")
    for rel in BASELINE_FILES:
        mark = "OK " if _check_exists(repo, rel) else "MISS"
        typer.echo(f"  [{mark}] {rel}")

    typer.echo()
    typer.echo("control primitives:")
    for primitive in Primitive:
        present, total = _primitive_status(repo, primitive)
        mark = "OK " if present == total else "PARTIAL" if present > 0 else "MISS"
        typer.echo(f"  [{mark}] {primitive.value}: {present}/{total}")


@primitive_app.command("list")
def primitive_list() -> None:
    """List available control primitives and their files."""
    for primitive in Primitive:
        typer.echo(f"{primitive.value}")
        for rel in PRIMITIVE_FILES[primitive]:
            typer.echo(f"  - {rel}")


@primitive_app.command("add")
def primitive_add(
    primitives: List[Primitive] = typer.Argument(..., help="Primitive names to add."),
    repo_path: Path = typer.Option(Path("."), "--repo", "-r", help="Target repository path."),
    force: bool = typer.Option(False, "--force", help="Overwrite existing primitive files."),
) -> None:
    """Add specific control primitives to a repository."""
    repo = _resolve_repo(repo_path)
    _add_primitives(repo, primitives, force=force)
    typer.secho("\nPrimitive update complete.", fg=typer.colors.GREEN)


if __name__ == "__main__":
    app()
