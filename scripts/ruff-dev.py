import shlex
from collections.abc import Iterable
from pathlib import Path
from typing import Annotated, Optional

import typer
import watchfiles

PLAYGROUND_DIR = Path.home().joinpath("playground", "ruff")
RUFF_DIR = Path.home().joinpath("work", "astral", "ruff")
RUFF_FIXTURES_DIR = RUFF_DIR.joinpath("crates", "ruff", "resources", "test", "fixtures")

app = typer.Typer(rich_markup_mode="rich")


def start_watchfiles(*paths: Path | str, command: Iterable[str]) -> None:
    """Start a watchfiles process."""
    typer.secho(
        f"Starting watchfiles for '{typer.style(command, fg=typer.colors.GREEN, bold=True)}'..."  # noqa: E501
    )
    typer.secho(
        "Watching the following paths for changes:\n"
        + "\n".join(f"  * {typer.style(path, bold=True)}" for path in paths)
    )
    watchfiles.run_process(
        *paths,
        target=" ".join(command),
        target_type="command",
    )


@app.command()
def docs() -> None:
    """Watch for changes in docs and generate them."""
    start_watchfiles(
        "crates/ruff",
        "mkdocs.template.yml",
        "mkdocs.insiders.yml",
        "scripts/generate_mkdocs.py",
        # Only include the files that aren't auto-generated.
        "docs/tutorial.md",
        "docs/installation.md",
        "docs/usage.md",
        "docs/configuration.md",
        "docs/editor-integrations.md",
        "docs/faq.md",
        command=["python", "scripts/generate_mkdocs.py"],
    )


@app.command()
def formatter() -> None:
    """Watch for changes in `ruff_python_formatter` and build it."""
    start_watchfiles(
        "crates/ruff_python_formatter",
        command=["cargo", "build", "--bin", "ruff_python_formatter"],
    )


@app.command()
def linter(
    rule: Annotated[
        Optional[str],
        typer.Option("--rule", "-r", metavar="[RULE]", help="Rule code to run"),
    ] = None,
    play: Annotated[
        bool,
        typer.Option("--play", "-p", help="Use the fixture from playground"),
    ] = False,
    ruff_args: Annotated[
        Optional[list[str]],
        typer.Argument(
            metavar="-- [RUFF_ARGS]...",
            help="Anything after -- will be passed to [cyan bold]ruff check ...[/]",
            show_default=False,
        ),
    ] = None,
) -> None:
    """Help with Ruff rule development.

    If no rule is specified, it will watch for changes in the `ruff` crate and build it.

    If a rule is specified, it will watch for changes in the fixture files related to
    that rule and run the `check` command for that rule. If unable to find any fixture
    file, it will exit with an error.

    If `--play` is specified, it will use the fixture file from the playground instead,
    and create it if it doesn't exist.
    """
    if rule is None:
        start_watchfiles(
            RUFF_DIR.joinpath("crates", "ruff"),
            command=[
                "cargo",
                "build",
                "--all-features",
                "--bin=ruff",
                "--package=ruff_cli",
            ],
        )
        return

    if play:
        playground_file = PLAYGROUND_DIR.joinpath("src", f"{rule}.py")
        if not playground_file.exists():
            typer.secho(
                f"Creating {typer.style(playground_file, fg=typer.colors.GREEN)}..."
            )
            playground_file.parent.mkdir(parents=True, exist_ok=True)
            playground_file.touch()
        fixture_paths = [shlex.quote(str(playground_file))]
    else:
        fixture_paths = [
            shlex.quote(str(fixture_path.relative_to(RUFF_DIR)))
            for fixture_path in RUFF_FIXTURES_DIR.glob(f"**/*{rule}*.py*")
        ]

    if not fixture_paths:
        typer.secho(
            (
                "Unable to find any fixture file for rule "
                + typer.style(repr(rule), bold=True)
            ),
            err=True,
            fg=typer.colors.RED,
        )
        raise typer.Exit(1)

    start_watchfiles(
        "crates/ruff",
        *fixture_paths,
        command=[
            "cargo",
            "run",
            "--all-features",
            "--bin=ruff",
            "--package=ruff_cli",
            "--",
            "check",
            f"--select={rule}",
            "--no-cache",
            "--show-source",
            *(ruff_args or []),
            " ".join(fixture_paths),
        ],
    )


@app.callback(
    invoke_without_command=True,
    no_args_is_help=True,
)
def main() -> None:
    """A CLI tool to help with Ruff development."""
    if Path.cwd() != RUFF_DIR:
        typer.secho(
            "This script must be run from " + typer.style(RUFF_DIR, bold=True),
            err=True,
            fg=typer.colors.RED,
        )
        raise typer.Exit(1)


if __name__ == "__main__":
    app()
