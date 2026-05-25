# cross-ai-template

A drop-in scaffold that gives **every** AI coding tool in your repo the same operating
contract, lifecycle, skills, personas, and commands — from **one source of truth**.

You edit `.ai/`. A single generator (`scripts/sync-ai-docs.ts`) materializes the tool-specific
configs for **Claude Code, Cursor, Codex, Gemini CLI, and opencode**. No more hand-maintaining
`CLAUDE.md`, `.cursor/rules`, and a Gemini config separately and watching them drift.

## How it works

```
.ai/                      ← the ONLY files you hand-edit (source of truth)
 ├─ context.md            project contract (stack, Definition of Done, hard rules)
 ├─ pipeline.md           the generic spec→plan→build→test→review lifecycle
 ├─ commands/*.md         slash-command definitions
 ├─ agents/*.md           reviewer personas (code / security / performance / test)
 ├─ skills/*/SKILL.md     reusable workflow skills (TDD, code review, CI/CD, …)
 ├─ references/*.md       checklists the skills/personas cite
 ├─ specs/*.md            your project's requirements / spec / plan / review / acceptance
 └─ memory.example.md     seed for the local, gitignored working log

      │   bun run sync:ai      (scripts/sync-ai-docs.ts — deterministic)
      ▼
AGENTS.md · CLAUDE.md · GEMINI.md · .ai/generated/rules.mdc      ← contract entry files
.claude/ · .gemini/ (TOML) · .opencode/ · .cursor/ (symlink)     ← per-tool mirrors
```

| Tool | Reads | Produced as |
|------|-------|-------------|
| Claude Code | `CLAUDE.md` + `.claude/{commands,agents,skills}` | `@`-import stub + copied assets |
| Cursor | `.cursor/rules/00-context.mdc` | symlink → `.ai/generated/rules.mdc` |
| Codex | `AGENTS.md` + `.codex/config.toml` | inlined contract + MCP config |
| Gemini CLI | `GEMINI.md` + `.gemini/{commands(TOML),agents,skills}` | `@`-import stub + transformed assets |
| opencode | `.ai/*` directly + `.opencode/{commands,agents}` | reads source + copied assets |

**Never edit a generated file** — your edit is overwritten on the next sync, and the
pre-commit hook blocks committing a stale one. Change a convention in `.ai/`, run
`bun run sync:ai`, commit.

## Quick start (adopt into your repo)

1. Copy `.ai/`, `scripts/`, `package.json`, `.gitignore`, `.githooks/`, and the per-tool dirs
   (`.claude/ .gemini/ .opencode/ .cursor/ .codex/ .mcp.json`) into your repo — or start your
   repo from this template.
2. Install the sync tooling and wire the hook:
   ```sh
   bun install        # runs the `prepare` script → git config core.hooksPath .githooks
   ```
   (If your repo already has a `package.json`, just copy the `scripts` entries and run
   `git config core.hooksPath .githooks` once.)
3. **Fill the contract** — edit `.ai/context.md`: your Project, locked Stack, Definition of
   Done, and hard rules. Look for the `<!-- FILL: … -->` markers.
4. Regenerate:
   ```sh
   bun run sync:ai
   ```
5. Open the repo in any supported tool — it now follows the same contract everywhere.

## Filling the specs (two ways)

`.ai/specs/` ships as **empty skeletons** — the section headings *are* the required format.
Populate them either way:

- **By hand** — edit `00-requirements.md` → `01-spec.md` → `02-plan.md`, following the headings
  and replacing the `<!-- TODO -->` markers.
- **With the agent (recommended)** — this template already includes the spec generator. Run the
  lifecycle commands and let the agent write the files:
  ```
  /spec     # → fills .ai/specs/01-spec.md   (skill: spec-driven-development)
  /plan     # → fills .ai/specs/02-plan.md   (skill: planning-and-task-breakdown)
  ```
  Optional: `/excalidraw-spec` renders the architecture diagram via the excalidraw MCP server.

You don't need an external spec tool — `/spec` + the `spec-driven-development` skill *are* the
"open-spec" workflow, built in.

## The lifecycle

Per vertical slice: `/spec → /plan → /build → /test → /review`.
Once, at the end: `/consensus-review → /code-simplify → /ship → /acceptance → /goal`.
Full definition: [`.ai/pipeline.md`](.ai/pipeline.md).

## What's included

- **Commands** (`.ai/commands/`): `spec`, `plan`, `build`, `test`, `review`,
  `consensus-review`, `code-simplify`, `ship`, `acceptance`, `excalidraw-spec`.
- **Personas** (`.ai/agents/`): `code-reviewer`, `security-auditor`, `performance-reviewer`,
  `test-engineer`. See [`.ai/agents/README.md`](.ai/agents/README.md).
- **Skills** (`.ai/skills/`): ~24 stack-agnostic workflows — TDD, code review, CI/CD,
  incremental implementation, security hardening, debugging, API design, and more.
- **References** (`.ai/references/`): checklists the personas/skills cite.

## Memory

`.ai/memory.md` is a **local, gitignored** per-developer working log, seeded from
`.ai/memory.example.md` on first sync. Terse `symptom → root cause → fix` entries. Durable,
team-facing decisions go in commit messages or `docs/adr/`, not here. Never write secrets.

## MCP servers

`.mcp.json` ships one server: `excalidraw` (used by `/excalidraw-spec`). Add your own
(database, search, etc.) there; `.codex/config.toml` mirrors MCP config for Codex.

## Keeping it in sync

- `bun run sync:ai` — regenerate everything from `.ai/`.
- `bun run check:sync` — regenerate and fail if anything changed (use in CI).
- `.githooks/pre-commit` runs the check automatically once
  `git config core.hooksPath .githooks` is set (done by `bun install`).
