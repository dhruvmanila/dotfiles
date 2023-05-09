import argparse
import shlex
from pathlib import Path

import watchfiles

PLAYGROUND_DIR = Path.home().joinpath("playground", "python", "ruff-play")
RUFF_DIR = Path.home().joinpath("contributing", "astral", "ruff")
RUFF_FIXTURES_DIR = RUFF_DIR.joinpath("crates", "ruff", "resources", "test", "fixtures")

DESCRIPTION = """
A tool to help in `ruff` development.
"""


def main() -> int:
    parser = argparse.ArgumentParser(description=DESCRIPTION)
    parser.add_argument("rule", help="rule to run")
    parser.add_argument(
        "--play", action="store_true", help="use the fixture from playground"
    )
    parser.add_argument(
        "ruff_args",
        nargs="*",
        metavar="-- RUFF_ARGS",
        help="anything after -- will be passed to ruff",
    )
    args = parser.parse_intermixed_args()

    if Path.cwd() != RUFF_DIR:
        print(f"This script must be run from {str(RUFF_DIR)!r}")
        return 1

    if args.play:
        playground_file = PLAYGROUND_DIR.joinpath("src", f"{args.rule}.py")
        if not playground_file.exists():
            print(f"Creating {str(playground_file)!r}...")
            playground_file.parent.mkdir(parents=True, exist_ok=True)
            playground_file.touch()
        fixture_paths = [shlex.quote(str(playground_file))]
    else:
        fixture_paths = [
            shlex.quote(str(fixture_path.relative_to(RUFF_DIR)))
            for fixture_path in RUFF_FIXTURES_DIR.glob(f"**/*{args.rule}*.py*")
        ]

    if not fixture_paths:
        print(f"Unable to find any fixture file for rule {args.rule!r}")
        return 1

    watchfiles.run_process(
        RUFF_DIR.joinpath("crates", "ruff"),
        *fixture_paths,
        target=" ".join(
            [
                "cargo",
                "run",
                "--bin=ruff",
                "--",
                "check",
                f"--select={args.rule}",
                "--no-cache",
                "--show-source",
                *args.ruff_args,
                " ".join(fixture_paths),
            ]
        ),
        target_type="command",
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
