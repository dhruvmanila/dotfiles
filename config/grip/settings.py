#!/usr/bin/env python3


def get_access_token() -> str:
    import subprocess

    result = subprocess.run(
        ["pass", "show", "token/github/grip"],
        capture_output=True,
        encoding="utf-8",
    )
    if result.returncode:
        print(f"ERROR: unable to get 'token/github/grip': {result.stderr}")
        return ""

    return result.stdout.strip()


USERNAME = "dhruvmanila"
PASSWORD = get_access_token()

# `settings.py` location. Default: `~/.grip`
GRIPHOME = "~/.config/grip"
