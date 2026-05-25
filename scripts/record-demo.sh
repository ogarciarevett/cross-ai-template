#!/usr/bin/env bash
#
# record-demo.sh — record a terminal walkthrough of your app/CLI for the README.
#
# The recorder harness is generic; fill in run_steps() with the commands that demonstrate
# YOUR project (start it, hit an endpoint, show output, etc.).
#
# Recorder preference:
#   1) asciinema           → docs/imgs/demo.cast  (+ demo.gif if `agg` is installed)  [best for a CLI demo]
#   2) macOS screencapture → docs/imgs/demo.mov   (records the whole screen)
#
# Usage:
#   ./scripts/record-demo.sh                 # record using whatever recorder is installed
#   bash ./scripts/record-demo.sh --steps    # run the demo steps without recording
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT/docs/imgs"
CAST="$OUT_DIR/demo.cast"

cyan() { printf '\033[1;36m%s\033[0m\n' "$*"; }
step() { echo; cyan "\$ $*"; }

# ----------------------------------------------------------------------------
# TODO: replace the body of run_steps() with the commands that demo YOUR project.
# Use `step "..."` to echo a labeled command, then run it. Keep it short and linear.
# ----------------------------------------------------------------------------
run_steps() {
	step "echo 'Edit run_steps() in scripts/record-demo.sh to script your demo'"
	echo "Replace run_steps() with your project's demo steps."

	# Example shape:
	# step "curl -s http://localhost:3000/health"
	# curl -s http://localhost:3000/health; echo; sleep 1.5
}

# Re-entrant: the recorders below invoke this script with --steps to run the scripted flow.
if [[ "${1:-}" == "--steps" ]]; then run_steps; exit 0; fi

mkdir -p "$OUT_DIR"

if command -v asciinema >/dev/null 2>&1; then
	cyan "▶ Recording asciinema cast → $CAST"
	rm -f "$CAST"   # asciinema 3.x removed --overwrite; clear any stale file first
	asciinema rec -c "bash '${BASH_SOURCE[0]}' --steps" "$CAST"
	cyan "✔ Saved $CAST"
	if command -v agg >/dev/null 2>&1; then
		agg "$CAST" "${CAST%.cast}.gif" && cyan "✔ Rendered GIF → ${CAST%.cast}.gif"
	else
		echo "Tip: render a README GIF →  brew install agg && agg '$CAST' '${CAST%.cast}.gif'"
	fi
elif command -v screencapture >/dev/null 2>&1; then
	mov="$OUT_DIR/demo.mov"
	cyan "asciinema not found — using macOS screen recording → $mov"
	screencapture -v "$mov" & rec=$!
	sleep 1
	bash "${BASH_SOURCE[0]}" --steps
	kill -INT "$rec" 2>/dev/null || true   # SIGINT tells screencapture to finalize the file
	wait "$rec" 2>/dev/null || true
	cyan "✔ Saved $mov"
else
	echo "No recorder found. Install asciinema (brew install asciinema), or run unrecorded:"
	echo "  bash '${BASH_SOURCE[0]}' --steps"
fi
