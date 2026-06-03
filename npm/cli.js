#!/usr/bin/env node
'use strict';
// Thin convenience wrapper over scripts/update-from-template.sh.
//
// It shallow-clones the template, then hands off to the canonical POSIX updater against the
// current directory. There is NO business logic here — the shell script is the brain. This
// only spares Node users from cloning by hand:
//
//   npx @ogarciarevett/cross-ai-template update [--ref <ref>] [--with-tooling] [--dry-run] [--force]
//
// Like the shell script, it NEVER pushes, commits, or touches a remote.
const { spawnSync } = require('child_process');
const { mkdtempSync, rmSync, existsSync } = require('fs');
const os = require('os');
const path = require('path');

const TEMPLATE_URL = 'https://github.com/ogarciarevett/cross-ai-template.git';

function main() {
  const argv = process.argv.slice(2);
  // Accept (and drop) an optional leading `update` verb: `npx ... update --dry-run`.
  const args = argv[0] === 'update' ? argv.slice(1) : argv.slice();

  if (args.includes('-h') || args.includes('--help')) {
    process.stdout.write(
      'Usage: npx @ogarciarevett/cross-ai-template update ' +
        '[--ref <ref>] [--template <url>] [--with-tooling] [--dry-run] [--force]\n\n' +
        'Pulls generic cross-ai-template updates into the current repo. Never pushes.\n'
    );
    return;
  }

  // --ref / --template are consumed here (for the clone); everything else is forwarded
  // verbatim to scripts/update-from-template.sh.
  let ref = 'main';
  let template = TEMPLATE_URL;
  const forward = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--ref') ref = args[++i];
    else if (args[i] === '--template') template = args[++i];
    else forward.push(args[i]);
  }

  if (spawnSync('git', ['--version'], { stdio: 'ignore' }).status !== 0) {
    console.error('✗ git is required on PATH');
    process.exit(1);
  }

  const tmp = mkdtempSync(path.join(os.tmpdir(), 'cross-ai-template-'));
  try {
    console.error(`→ cloning ${template} @ ${ref} ...`);
    const clone = spawnSync(
      'git',
      ['clone', '--quiet', '--depth', '1', '--branch', ref, template, tmp],
      { stdio: 'inherit' }
    );
    if (clone.status !== 0) {
      console.error('✗ clone failed');
      process.exit(clone.status || 1);
    }

    const script = path.join(tmp, 'scripts', 'update-from-template.sh');
    if (!existsSync(script)) {
      console.error('✗ updater script missing in template clone');
      process.exit(1);
    }

    const run = spawnSync(
      'sh',
      [script, '--source', tmp, '--target', process.cwd(), ...forward],
      { stdio: 'inherit' }
    );
    process.exitCode = run.status == null ? 1 : run.status;
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
}

main();
