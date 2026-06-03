# cross-ai-template (Rust wrapper)

Pull [cross-ai-template](https://github.com/ogarciarevett/cross-ai-template) updates into a repo
you created from it.

```sh
cargo install cross-ai-template      # once on crates.io
cross-ai-template update             # run from inside your downstream repo
```

This is a **thin, std-only wrapper**: it shallow-clones the template and runs the canonical POSIX
updater, `scripts/update-from-template.sh` — the shell script holds all the logic. If your repo
already has the script (it does, once you've adopted the template), skip Rust entirely:

```sh
sh scripts/update-from-template.sh
```

It refreshes the **generic** half of the template (lifecycle, commands, agents, skills, sync
machinery, hooks), preserves your project-specific files (`.ai/context.md`, your specs, model
routing, language hooks, `.gitignore`), saves the template's new contract as
`.ai/context.md.incoming`, and **never** pushes.

Flags pass straight through: `--dry-run`, `--ref <branch|tag>`, `--template <url>`,
`--with-tooling`, `--force`.
