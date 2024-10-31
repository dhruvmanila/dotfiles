#!/usr/bin/env -S uv run --quiet

# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "typer[all]==0.9.0",
#     "watchfiles==0.21.0",
# ]
# ///

import shlex
from collections.abc import Iterable
from pathlib import Path
from typing import Annotated, Optional

import typer
import watchfiles

PLAYGROUND_DIR = Path.home() / "playground" / "ruff"
RUFF_DIR = Path.home() / "work" / "astral" / "ruff"
RUFF_TEST_DIR = Path.home() / "work" / "astral" / "ruff-test"
RUFF_DIR_CANDIDATES = (RUFF_DIR, RUFF_TEST_DIR)
RUFF_CONFIG_FILENAMES = ("pyproject.toml", "ruff.toml", ".ruff.toml")

app = typer.Typer(rich_markup_mode="rich")


def ruff_fixtures_dir() -> Path:
    """Returns the fixtures directory for the Ruff project.

    This function assumes that the current working directory is in `RUFF_DIR_CANDIDATES`.
    """
    return Path.cwd() / "crates" / "ruff_linter" / "resources" / "test" / "fixtures"


def playground_file(filepath: str) -> Path:
    """Returns the path which is inside the playground directory.

    This is done by joining the given path to the playground directory path.
    The file is created if it doesn't exists along with all of the parent directories.
    """
    playground_file = PLAYGROUND_DIR.joinpath(filepath)
    if not playground_file.exists():
        typer.secho(
            f"Creating {typer.style(playground_file, fg=typer.colors.GREEN)}..."
        )
        playground_file.parent.mkdir(parents=True, exist_ok=True)
        playground_file.touch()
    return playground_file


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
        "crates/ruff_linter",
        "crates/ruff_dev",
        "mkdocs.template.yml",
        "mkdocs.insiders.yml",
        "scripts/generate_mkdocs.py",
        # Only include the files that aren't auto-generated.
        "docs/editors",
        "docs/tutorial.md",
        "docs/installation.md",
        "docs/linter.md",
        "docs/formatter.md",
        "docs/configuration.md",
        "docs/preview.md",
        "docs/versioning.md",
        "docs/integrations.md",
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
def tokens(
    file: Annotated[Optional[Path], typer.Argument(...)] = None,
    play: Annotated[
        bool,
        typer.Option("--play", "-p", help="Use the fixture from playground"),
    ] = False,
) -> None:
    """Print the tokens in watch mode.

    If the file is not specified or if `--play` is specified, it will use the file
    from the playground instead, and create it if it doesn't exist. The playground
    file is at `~/playground/ruff/src/tokens.py`.
    """
    if file is None or play:
        file = playground_file("src/tokens.py")
    start_watchfiles(
        "crates/ruff_dev",
        "crates/ruff_python_ast",
        "crates/ruff_python_parser",
        str(file),
        command=["cargo", "dev", "print-tokens", str(file)],
    )


@app.command()
def ast(
    file: Annotated[Optional[Path], typer.Argument(...)] = None,
    play: Annotated[
        bool,
        typer.Option("--play", "-p", help="Use the fixture from playground"),
    ] = False,
) -> None:
    """Print the AST in watch mode.

    If the file is not specified or if `--play` is specified, it will use the file
    from the playground instead, and create it if it doesn't exist. The playground
    file is at `~/playground/ruff/parser/_.py`.
    """
    if file is None or play:
        file = playground_file("parser/_.py")
    start_watchfiles(
        "crates/ruff_dev",
        "crates/ruff_python_ast",
        "crates/ruff_python_parser",
        str(file),
        command=["cargo", "dev", "print-ast", str(file)],
    )


@app.command()
def linter(
    rules: Annotated[
        Optional[list[str]],
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

    If no rules are specified, it will watch for changes in the `ruff_linter` crate and
    build it.

    If any rules are specified, it will watch for changes in the fixture files related
    to that rule and run the `check` command for that rule. If it's unable to find any
    fixture file, it will exit with an error.

    Multiple rules can be specified by repeating the `--rule` option.

    If `--play` is specified, it will use the fixture file from the playground instead,
    and create it if it doesn't exist.
    """
    if rules is None:
        start_watchfiles(
            RUFF_DIR.joinpath("crates", "ruff_linter"),
            command=[
                "cargo",
                "build",
                "--all-features",
                "--bin=ruff",
                "--package=ruff",
            ],
        )
        return

    fixture_paths: list[str] = []
    for rule in rules:
        extension = "pyi" if rule.startswith("PYI") else "py"
        if play:
            fixture_paths.append(
                shlex.quote(str(playground_file(f"src/{rule}.{extension}")))
            )
        else:
            fixture_paths.extend(
                shlex.quote(str(fixture_path.relative_to(RUFF_DIR)))
                for fixture_path in ruff_fixtures_dir().glob(
                    f"**/*{rule}*.{extension}*"
                )
            )

    if not fixture_paths:
        s = "s" if len(rules) > 1 else ""
        typer.secho(
            (
                f"Unable to find any fixture file for rule{s} "
                + typer.style(", ".join(rules), bold=True)
            ),
            err=True,
            fg=typer.colors.RED,
        )
        raise typer.Exit(1)

    watch_paths = []
    if play:
        config_file = shlex.quote(str(playground_file("pyproject.toml")))
        config_option = f"--config={config_file}"
        watch_paths.extend(fixture_paths)
        watch_paths.append(config_file)
    else:
        config_option = "--isolated"

    start_watchfiles(
        # The linter crate itself...
        "crates/ruff_linter",
        # ... and the dependencies of `ruff_linter`
        "crates/ruff_cache",
        "crates/ruff_diagnostics",
        "crates/ruff_notebook",
        "crates/ruff_macros",
        "crates/ruff_python_ast",
        "crates/ruff_python_codegen",
        "crates/ruff_python_index",
        "crates/ruff_python_literal",
        "crates/ruff_python_semantic",
        "crates/ruff_python_stdlib",
        "crates/ruff_python_trivia",
        "crates/ruff_python_parser",
        "crates/ruff_source_file",
        "crates/ruff_text_size",
        *watch_paths,
        command=[
            "cargo",
            "run",
            "--all-features",
            "--bin=ruff",
            "--package=ruff",
            "--",
            "check",
            f"--select={','.join(rules)}",
            config_option,
            "--no-cache",
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
    if Path.cwd() not in RUFF_DIR_CANDIDATES:
        typer.echo(
            "\n".join(
                (
                    typer.style(
                        "This script must be run from either of the following directories:",
                        fg=typer.colors.YELLOW,
                        bold=True,
                    ),
                    *map(lambda path: f"* {path}", RUFF_DIR_CANDIDATES),
                ),
            ),
            err=True,
        )
        raise typer.Exit(1)


if __name__ == "__main__":
    app()
