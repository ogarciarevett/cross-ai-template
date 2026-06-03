"""Thin wrapper over scripts/update-from-template.sh.

Clones the cross-ai-template repo and hands off to the canonical POSIX updater against the
current directory. No business logic lives here — the shell script is the brain. This only
spares Python users from cloning by hand:

    uvx cross-ai-template update            # or: pipx run cross-ai-template update

Like the shell script, it NEVER pushes, commits, or touches a remote. Standard library only.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile

TEMPLATE_URL = "https://github.com/ogarciarevett/cross-ai-template.git"

_HELP = (
    "Usage: uvx cross-ai-template update "
    "[--ref <ref>] [--template <url>] [--with-tooling] [--dry-run] [--force]\n\n"
    "Pulls generic cross-ai-template updates into the current repo. Never pushes."
)


def main() -> None:
    argv = sys.argv[1:]
    # Accept (and drop) an optional leading `update` verb: `uvx cross-ai-template update ...`.
    args = list(argv[1:]) if argv[:1] == ["update"] else list(argv)

    if "-h" in args or "--help" in args:
        print(_HELP)
        return

    # --ref / --template are consumed here (for the clone); the rest is forwarded verbatim.
    git_ref = "main"
    template = TEMPLATE_URL
    forward: "list[str]" = []
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--ref":
            i += 1
            git_ref = args[i] if i < len(args) else git_ref
        elif arg == "--template":
            i += 1
            template = args[i] if i < len(args) else template
        else:
            forward.append(arg)
        i += 1

    if shutil.which("git") is None:
        sys.exit("✗ git is required on PATH")

    tmp = tempfile.mkdtemp(prefix="cross-ai-template-")
    try:
        print(f"→ cloning {template} @ {git_ref} ...", file=sys.stderr)
        clone = subprocess.run(
            ["git", "clone", "--quiet", "--depth", "1", "--branch", git_ref, template, tmp]
        )
        if clone.returncode != 0:
            sys.exit("✗ clone failed")

        script = os.path.join(tmp, "scripts", "update-from-template.sh")
        if not os.path.exists(script):
            sys.exit("✗ updater script missing in template clone")

        run = subprocess.run(
            ["sh", script, "--source", tmp, "--target", os.getcwd(), *forward]
        )
        sys.exit(run.returncode)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
