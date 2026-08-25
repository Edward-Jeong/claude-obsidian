# Codex primary-host guide

Codex is the primary portable Agent Skills host for this repository. The
knowledge behavior remains agent-neutral: canonical workflows live in
`skills/`, deterministic mutation and retrieval live in `claude_obsidian/`, and
host integrations only expose those capabilities to an agent runtime.

Claude Code remains supported through its plugin adapter. OpenCode, Gemini,
Cursor, and Windsurf remain supported as explicit compatibility hosts.

## Architecture

```text
Codex
  |
  v
~/.agents/skills/<skill>/SKILL.md
  |
  v
product repository/skills/<skill>/SKILL.md
  |
  v
claude_obsidian/ + scripts/claude-obsidian.py
  |
  v
user-owned Obsidian vault
```

The product repository and the user vault are separate trust boundaries. Never
use the product checkout, plugin cache, or host skill directory as the mutable
vault.

## Requirements

- Python 3.11 or newer
- Bash for setup and shell tests
- Codex with Agent Skills discovery
- Obsidian only when the visual vault experience is wanted
- WSL for vault writes on Windows; native Windows is limited to inspection and
  dry-run workflows

## Install the Codex skills

From the product checkout, preview the default installation:

```bash
bash bin/setup-multi-agent.sh
```

The default target is Codex and the expected user-level discovery root is:

```text
~/.agents/skills/<skill>
```

Apply only after reviewing the planned links:

```bash
bash bin/setup-multi-agent.sh --apply
```

Check an existing installation without changing it:

```bash
bash bin/setup-multi-agent.sh --check
```

You may also state the host explicitly:

```bash
bash bin/setup-multi-agent.sh --host codex --apply
```

Existing files and links pointing somewhere else are never overwritten.

## Initialize or adopt a vault

Create a new vault by reviewing the generated operation first:

```bash
python3 scripts/claude-obsidian.py init <vault> \
  --generated-at <ISO-UTC> --operation-id init-reviewed
```

Apply only the reviewed operation hash:

```bash
python3 scripts/claude-obsidian.py init <vault> \
  --generated-at <ISO-UTC> --operation-id init-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

For an existing Obsidian vault use `adopt` instead of `init`.

Verify the selected vault before knowledge operations:

```bash
python3 scripts/claude-obsidian.py doctor --vault <vault>
python3 scripts/claude-obsidian.py contracts --verify --vault <vault>
```

## Codex operating contract

When Codex works in this repository or an initialized vault:

1. Read the applicable `AGENTS.md` instructions.
2. Read the selected `skills/<name>/SKILL.md` completely.
3. Read only references routed by that skill.
4. Resolve the user vault explicitly or through `.claude-obsidian.json`.
5. For mutations, generate and inspect one recoverable transaction before
   applying it.
6. Report the operation ID and exact changed paths.

Parallel workers may return drafts and evidence, but they must not write shared
vault state directly.

## Compatibility hosts

Codex is the default, but other portable hosts remain available explicitly:

```bash
bash bin/setup-multi-agent.sh --host opencode --apply
bash bin/setup-multi-agent.sh --host gemini --apply
```

Cursor and Windsurf require a workspace destination:

```bash
bash bin/setup-multi-agent.sh --host cursor --workspace <workspace> --apply
bash bin/setup-multi-agent.sh --host windsurf --workspace <workspace> --apply
```

Claude Code keeps its plugin-specific marketplace and namespaced skill adapter;
that adapter is compatibility infrastructure rather than the source of
knowledge behavior.

## Verification

Behavioral changes must pass the repository verification contract:

```bash
make test
```

The Codex-primary setup behavior is covered by
`tests/test_setup_multi_agent.sh`, including default dry-run, apply, readiness
check, and explicit compatibility-host selection.
