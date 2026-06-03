# @ogarciarevett/cross-ai-template

Pull [cross-ai-template](https://github.com/ogarciarevett/cross-ai-template) updates into a
repo you created from it — without cloning by hand.

```sh
# from inside your downstream repo:
npx @ogarciarevett/cross-ai-template update
```

This is a **thin convenience wrapper**. It shallow-clones the template and runs the canonical
POSIX updater, `scripts/update-from-template.sh` — the shell script holds all the logic. If you
already have the script in your repo (you do, if you adopted the template), you can skip Node
entirely:

```sh
sh scripts/update-from-template.sh
```

## What it does

Refreshes only the **generic** half of the template — the lifecycle (`.ai/pipeline.md`),
commands, agents, skills, references, the sync machinery, and the dispatcher hooks — then
re-runs the sync so every tool's generated config matches. It **preserves** your project-specific
files (`.ai/context.md`, your specs, opencode model routing, language hooks, `.gitignore`) and
saves the template's new `.ai/context.md` as `.ai/context.md.incoming` for you to reconcile.

It **never** pushes, commits, or touches a remote — you review the diff and commit locally.

## Options

| Flag | Meaning |
| --- | --- |
| `--ref <branch\|tag\|sha>` | Template ref to pull (default `main`). |
| `--template <git-url>` | Template repo URL (default the canonical GitHub HTTPS URL). |
| `--with-tooling` | Also refresh root tool configs (`.mcp.json`, `opencode.json`, `.codex/`, `.agents/`). Off by default. |
| `--dry-run` | Print what would change; touch nothing. |
| `--force` | Proceed even if the working tree is dirty. |

## Tip: let the agent do the merge

The one fuzzy step is reconciling `.ai/context.md` (new template conventions vs. your filled-in
values). Run the `/update-from-template` slash command in any of the supported CLIs (Claude Code,
Codex, Gemini, opencode) and the agent performs that judgment merge for you.
