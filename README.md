<!-- logo: figlet "ANSI Shadow" — regenerate with:  figlet -f "ANSI Shadow" "cross-ai" -->
```
 ██████╗██████╗  ██████╗ ███████╗███████╗       █████╗ ██╗
██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔════╝      ██╔══██╗██║
██║     ██████╔╝██║   ██║███████╗███████╗█████╗███████║██║
██║     ██╔══██╗██║   ██║╚════██║╚════██║╚════╝██╔══██║██║
╚██████╗██║  ██║╚██████╔╝███████║███████║      ██║  ██║██║
 ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝      ╚═╝  ╚═╝╚═╝
```

<div align="center">

# cross-ai-template

**One operating contract for every AI coding tool — from a single source of truth.**

![Claude Code](https://img.shields.io/badge/Claude_Code-D97757?style=for-the-badge)
![Cursor](https://img.shields.io/badge/Cursor-000000?style=for-the-badge)
![Codex](https://img.shields.io/badge/Codex-412991?style=for-the-badge)
![Gemini CLI](https://img.shields.io/badge/Gemini_CLI-4285F4?style=for-the-badge)
![opencode](https://img.shields.io/badge/opencode-FF6B00?style=for-the-badge)

![skills](https://img.shields.io/badge/skills-25-8b5cf6?style=flat-square)
![commands](https://img.shields.io/badge/commands-12-06b6d4?style=flat-square)
![personas](https://img.shields.io/badge/personas-4-ec4899?style=flat-square)
![config drift](https://img.shields.io/badge/config_drift-zero-22c55e?style=flat-square)
![sync](https://img.shields.io/badge/sync-POSIX_shell-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![runtime deps](https://img.shields.io/badge/runtime_deps-none-22c55e?style=flat-square)

</div>

A drop-in scaffold that gives **every** AI coding tool in your repo the same operating
contract, lifecycle, skills, personas, and commands — from **one source of truth**.

You edit `.ai/`. A single generator (`scripts/sync-ai-docs.sh` — **dependency-free POSIX shell**,
no node/bun/python) materializes the tool-specific configs for **Claude Code, Cursor, Codex,
Gemini CLI, and opencode**. No more hand-maintaining `CLAUDE.md`, `.cursor/rules`, and a Gemini
config separately and watching them drift. Drop it into a project in **any language** — the
machinery needs nothing but a shell.

## 🎬 See it in action

![cross-ai-template — one .ai/ edit fans out to every tool, with a drift gate](docs/imgs/demo.gif)

One edit to `.ai/context.md` → `sh scripts/sync-ai-docs.sh` → the same rule lands in every
tool's config: inlined into `AGENTS.md`/`.cursor` (Codex, Cursor, GitHub web) and `@`-imported
by the `CLAUDE.md`/`GEMINI.md` stubs. Then the pre-commit hook re-runs the sync and **blocks** a
contract edit that wasn't re-synced.

## 🧩 How it works

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

      │   sh scripts/sync-ai-docs.sh   (POSIX shell, no runtime deps — deterministic)
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
`sh scripts/sync-ai-docs.sh`, commit.

## ⚡ Quick start (adopt into your repo)

1. Copy `.ai/`, `scripts/`, `.gitignore`, `.githooks/`, and the per-tool dirs
   (`.claude/ .gemini/ .opencode/ .cursor/ .codex/ .mcp.json`) into your repo — or start your
   repo from this template. **No `package.json` needed** — the machinery is pure shell.
2. Install the hooks and run the first sync (one command, no runtime to install):
   ```sh
   sh scripts/install.sh   # git config core.hooksPath .githooks + chmod + first sync
   ```
3. **Fill the contract** — two ways:
   - **Fastest:** open the repo in your AI tool and run **`/bootstrap`** — it interviews you,
     fills `.ai/context.md` (and can seed the specs), **wires your language's pre-commit /
     post-commit hooks**, and runs the sync for you.
   - **By hand:** edit `.ai/context.md` (your Project, locked Stack, Definition of Done, hard
     rules — look for the `<!-- FILL: … -->` markers), and drop your language's checks into
     `.githooks/pre-commit.d/` and `.githooks/post-commit.d/` (see those dirs' READMEs).
4. Regenerate (skip if you ran `/bootstrap` or `install.sh` — they already synced):
   ```sh
   sh scripts/sync-ai-docs.sh
   ```
5. Open the repo in any supported tool — it now follows the same contract everywhere.

## 📐 Filling the specs (two ways)

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

## 🔁 The lifecycle

Per vertical slice: `/spec → /plan → /build → /test → /review`.
Once, at the end: `/consensus-review → /code-simplify → /ship → /acceptance → /goal`.
Optional, on a cadence: `/evolve` — re-sync the `.ai/` contract to the code (all CLIs;
`/graphify` accelerates it on Claude Code).
Full definition: [`.ai/pipeline.md`](.ai/pipeline.md).

## 🎚️ Per-stage model routing (opencode)

The lifecycle stages are just commands, so you can run **each stage on the best-fit model** —
cheap/fast for mechanical work, frontier for reasoning — to optimize cost and tokens. This is
**opt-in** and applies to **opencode** (the model-agnostic CLI). Single-vendor tools optimize
*within* their own ladder instead (Claude Code routes Haiku↔Sonnet↔Opus) and ignore the key, so
the same sources stay valid everywhere.

Add an optional `model:` key to any command or persona's frontmatter — opencode honors it on both
`.opencode/commands/` and `.opencode/agents/`:

```yaml
---
description: Implement the next task incrementally — build, test, verify, commit
model: openrouter/anthropic/claude-sonnet-4   # capable model for implementation
---
```

A sensible cheap↔frontier map across the lifecycle (tune to taste; pull current model ids from
[models.dev](https://models.dev)):

| Stage | Tier | Why |
|-------|------|-----|
| `/spec`, `/review`, `/consensus-review` | frontier | contract design, subtle-bug catching |
| `/build` | capable | implementation correctness |
| `/plan`, `/test`, `/code-simplify` | fast/cheap | decomposition, red-green, mechanical edits |
| `/ship` | cheap | mechanical commits |

**One bill, every vendor.** Point opencode at [OpenRouter](https://openrouter.ai) so adopting a
newly released model is a one-line change, not a new subscription. In `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "openrouter": { "options": { "apiKey": "{env:OPENROUTER_API_KEY}" } }
  },
  "model": "openrouter/anthropic/claude-sonnet-4"
}
```

**Keep `.ai/` vendor-neutral.** Don't hardcode a provider's model id into a *committed* template
command — that would betray the agnostic point. Per-stage routing is something a downstream
project opts into for its own opencode runtime; the template just documents the convention.
Automatic routers (OpenRouter's `openrouter/auto`, etc.) exist but optimize for quality, not cost
— a declared per-stage map is the predictable choice.

## 📦 What's included

- **Commands** (`.ai/commands/`): `bootstrap` (one-time setup), `spec`, `plan`, `build`,
  `test`, `review`, `consensus-review`, `code-simplify`, `ship`, `acceptance`, `excalidraw-spec`,
  and `evolve` (contract drift detection).
- **Personas** (`.ai/agents/`): `code-reviewer`, `security-auditor`, `performance-reviewer`,
  `test-engineer`. See [`.ai/agents/README.md`](.ai/agents/README.md).
- **Skills** (`.ai/skills/`): ~25 stack-agnostic workflows — TDD, code review, CI/CD,
  incremental implementation, security hardening, debugging, API design, plus `evolve`
  (graphify-backed contract-vs-code drift) and more.
- **Parallel fan-out** (no committed scripts): the `/consensus-review` 2-of-3 panel,
  file-disjoint parallel slices, and `/evolve`'s per-dimension scan all run on each tool's
  **native** parallelism — an Agent Team in Claude Code, sub-agents in Codex / Gemini /
  opencode. See the "Parallel work" section of [`.ai/pipeline.md`](.ai/pipeline.md). Keeping
  this language-/tool-agnostic (rather than shipping tool-specific scripts) is deliberate.
- **References** (`.ai/references/`): checklists the personas/skills cite.

## 🧠 Memory

`.ai/memory.md` is a **local, gitignored** per-developer working log, seeded from
`.ai/memory.example.md` on first sync. Terse `symptom → root cause → fix` entries. Durable,
team-facing decisions go in commit messages or `docs/adr/`, not here. Never write secrets.

## 🔌 MCP servers

`.mcp.json` ships one server: `excalidraw` (used by `/excalidraw-spec`). Add your own
(database, search, etc.) there; `.codex/config.toml` mirrors MCP config for Codex.

## 🔄 Keeping it in sync

- `sh scripts/sync-ai-docs.sh` — regenerate everything from `.ai/` (no runtime deps).
- `sh scripts/sync-ai-docs.sh && git diff --exit-code` — regenerate and fail if anything
  changed (use in CI).
- `.githooks/pre-commit` runs the sync gate automatically once
  `git config core.hooksPath .githooks` is set (done by `sh scripts/install.sh`), then runs
  any language checks you (or `/bootstrap`) put in `.githooks/pre-commit.d/`.

## 🪝 Commit hooks (language-specific)

The template's hooks are **agnostic dispatchers**: `pre-commit` runs the sync drift gate then
every executable in `.githooks/pre-commit.d/`; `post-commit` runs every executable in
`.githooks/post-commit.d/`. The template ships those `.d/` dirs **empty**. Run **`/bootstrap`**
and it writes your language's checks into them — `gofmt`/`go vet`/`go test`, `prettier`/`eslint`/
`tsc`/`npm test`, `ruff`/`black`/`mypy`/`pytest`, `cargo fmt`/`clippy`/`test`, etc. — using the
exact Definition-of-Done commands from your contract. Nothing language-specific ever touches the
dispatcher hooks or the sync script, so the core stays drop-in for any stack.
