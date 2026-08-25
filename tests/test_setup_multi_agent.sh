#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

HOME_DIR="$TMP_ROOT/home"
mkdir -p "$HOME_DIR"

output="$(HOME="$HOME_DIR" bash "$REPO_ROOT/bin/setup-multi-agent.sh")"

echo "$output" | grep -F "PLANNED codex $HOME_DIR/.agents/skills/wiki" >/dev/null
if echo "$output" | grep -F "PLANNED opencode" >/dev/null; then
  echo "default install unexpectedly planned OpenCode links" >&2
  exit 1
fi
if echo "$output" | grep -F "PLANNED gemini" >/dev/null; then
  echo "default install unexpectedly planned Gemini links" >&2
  exit 1
fi

echo "$output" | grep -F "Dry run only." >/dev/null

HOME="$HOME_DIR" bash "$REPO_ROOT/bin/setup-multi-agent.sh" --apply >/dev/null

expected="$REPO_ROOT/skills/wiki"
actual="$(readlink "$HOME_DIR/.agents/skills/wiki")"
[ "$actual" = "$expected" ] || {
  echo "Codex wiki link mismatch: expected $expected, got $actual" >&2
  exit 1
}

HOME="$HOME_DIR" bash "$REPO_ROOT/bin/setup-multi-agent.sh" --check >/dev/null

compat_output="$(HOME="$HOME_DIR" bash "$REPO_ROOT/bin/setup-multi-agent.sh" --host opencode)"
echo "$compat_output" | grep -F "PLANNED opencode $HOME_DIR/.config/opencode/skills/wiki" >/dev/null

printf '%s\n' "setup-multi-agent Codex-primary tests passed."
