//! Thin wrapper over `scripts/update-from-template.sh`.
//!
//! Clones the cross-ai-template repo and hands off to the canonical POSIX updater against the
//! current directory. No business logic lives here — the shell script is the brain. This only
//! spares Rust users from cloning by hand:
//!
//!   cargo install cross-ai-template && cross-ai-template update
//!
//! Like the shell script, it NEVER pushes, commits, or touches a remote. std-only, no deps.

use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::{exit, Command};

const TEMPLATE_URL: &str = "https://github.com/ogarciarevett/cross-ai-template.git";

fn main() {
    let mut args: Vec<String> = env::args().skip(1).collect();
    // Accept (and drop) an optional leading `update` verb.
    if args.first().map(String::as_str) == Some("update") {
        args.remove(0);
    }
    if args.iter().any(|a| a == "-h" || a == "--help") {
        println!(
            "Usage: cross-ai-template update [--ref <ref>] [--template <url>] \
[--with-tooling] [--dry-run] [--force]\n\n\
Pulls generic cross-ai-template updates into the current repo. Never pushes."
        );
        return;
    }

    // --ref / --template are consumed here (for the clone); the rest is forwarded verbatim.
    let mut git_ref = String::from("main");
    let mut template = String::from(TEMPLATE_URL);
    let mut forward: Vec<String> = Vec::new();
    let mut it = args.into_iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--ref" => git_ref = it.next().unwrap_or_default(),
            "--template" => template = it.next().unwrap_or_default(),
            _ => forward.push(a),
        }
    }

    let tmp = env::temp_dir().join(format!("cross-ai-template-{}", std::process::id()));
    let _ = fs::remove_dir_all(&tmp);

    eprintln!("→ cloning {} @ {} ...", template, git_ref);
    let cloned = Command::new("git")
        .args(["clone", "--quiet", "--depth", "1", "--branch"])
        .arg(&git_ref)
        .arg(&template)
        .arg(&tmp)
        .status()
        .map(|s| s.success())
        .unwrap_or(false);
    if !cloned {
        eprintln!("✗ clone failed (is git on PATH?)");
        exit(1);
    }

    let script = tmp.join("scripts").join("update-from-template.sh");
    if !script.exists() {
        eprintln!("✗ updater script missing in template clone");
        let _ = fs::remove_dir_all(&tmp);
        exit(1);
    }

    let target = env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    let mut cmd = Command::new("sh");
    cmd.arg(&script)
        .arg("--source")
        .arg(&tmp)
        .arg("--target")
        .arg(&target);
    for f in &forward {
        cmd.arg(f);
    }
    let code = cmd.status().ok().and_then(|s| s.code()).unwrap_or(1);
    let _ = fs::remove_dir_all(&tmp);
    exit(code);
}
