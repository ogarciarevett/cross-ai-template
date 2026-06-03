# cross-ai-template (Python wrapper)

Pull [cross-ai-template](https://github.com/ogarciarevett/cross-ai-template) updates into a repo
you created from it.

```sh
uvx cross-ai-template update          # uv (once on PyPI) — or: pipx run cross-ai-template update
```

Run it straight from git, no publish required:

```sh
uvx --from "git+https://github.com/ogarciarevett/cross-ai-template.git#subdirectory=pip" \
  cross-ai-template update
```

This is a **thin, stdlib-only wrapper**: it shallow-clones the template and runs the canonical
POSIX updater, `scripts/update-from-template.sh` — the shell script holds all the logic. If your
repo already has the script (it does, once you've adopted the template), skip Python entirely:

```sh
sh scripts/update-from-template.sh
```

It refreshes the **generic** half of the template (lifecycle, commands, agents, skills, sync
machinery, hooks), preserves your project-specific files (`.ai/context.md`, your specs, model
routing, language hooks, `.gitignore`), saves the template's new contract as
`.ai/context.md.incoming`, and **never** pushes.

Flags pass straight through: `--dry-run`, `--ref <branch|tag>`, `--template <url>`,
`--with-tooling`, `--force`.
