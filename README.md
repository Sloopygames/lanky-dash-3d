# Lanky Dash

A 3D endless **size-runner**. You auto-run down a three-lane track as a scrawny
stick figure. Steer through math gates to change your **POWER** ΓÇö `+5` and `├ù2`
make you taller and wider, `ΓêÆ3` and `├╖2` shrink you. Dodge spinning saws,
swinging hammers and brick walls (they knock your power down). Every stretch of
track ends in a **boss**: charge it, and if your POWER beats the number floating
over its head you smash clean through in a shower of debris and keep going,
faster. Too small? It swats you and the run is over.

The whole game is the satisfaction of turning a twig into a giant and watching
bosses explode.

## Controls

- **Steer:** `ΓåÉ` / `ΓåÆ` or `A` / `D` ΓÇö or drag / tap the left or right side of the
  screen (swipe on mobile).
- **Start / Retry:** `Space`, `Enter`, click, or tap.
- **Pause:** `P` or `Esc`.
- **Camera:** `C` or the `C` button (top-right) cycles Classic/Cute 3/4/Diag 3/4/First Person views.
- **Mute:** `M` or the speaker button (top-right).
- **Fullscreen:** the expand button (top-right).
- **Changelog:** `NEW` button (top-right).

## Features

- Procedural endless track that speeds up the further you get.
- `+`, `├ù`, `ΓêÆ`, `├╖` gates with real route-choice tension.
- Volatile high-reward gates, shield pickups, and overcharge risk/reward.
- Auto-smash bosses with escalating POWER thresholds.
- Multi-pattern bosses with telegraphed dodge windows.
- Squash-and-stretch growth, particle bursts, screen shake, hit-pause and slow-mo.
- Combo multiplier, mission cards, and achievement/meta stars.
- Biome progression with adaptive difficulty pacing and deterministic daily-seed mode.
- Adaptive quality scaling and in-game debug telemetry overlay.
- Procedural Web Audio music and SFX with a mute toggle.
- Desktop keyboard + mouse and full mobile touch support.
- Touch settings (drag/swipe, dead-zone), handedness toggle, cosmetics, and local save migration (legacy keys -> `lankydash_save_v2`).
- Best score + daily challenge best saved locally with share text support.

## Tech

Single self-contained `index.html`. Vanilla JavaScript with **Three.js**
(loaded from a CDN importmap) for 3D rendering and the **Web Audio API** for
procedural sound. No build step, no backend, no frameworks.

## Agent Automation

You can run repository agent prompts from terminal using:

- `scripts/run-agent-chat.ps1`
- `scripts/examples/recover-sequence.json`
- `scripts/examples/parallel-fanout-sequence.json`
- `scripts/examples/autonomous-parallel-5-iterations.json`

Set a token first:

- PowerShell: `$env:GITHUB_TOKEN = "<token>"`

Example calls:

- `pwsh ./scripts/run-agent-chat.ps1 -Agent exploration-operator -Prompt "Propose 3 improvements for onboarding readability."`
- `pwsh ./scripts/run-agent-chat.ps1 -Agent expressive-chaos-explorer -Prompt "Generate 5 high-novelty happy-hardcore event trajectories."`
- `pwsh ./scripts/run-agent-chat.ps1 -Agent governance-auditor -Prompt "Audit current repo state with Intent -> Admissibility -> Coverage -> Integrity -> Evidence -> Stop/Recover."`
- `pwsh ./scripts/run-agent-chat.ps1 -Agent exploration-operator -Prompt "Implement the requested fix in index.html." -AllowEdits -SessionName feature-fix`
- `pwsh ./scripts/run-agent-chat.ps1 -SequencePath ./scripts/examples/recover-sequence.json -SessionName recover-demo`
- `pwsh ./scripts/run-agent-chat.ps1 -SequencePath ./scripts/examples/parallel-fanout-sequence.json -SessionName fanout-demo`
- `pwsh ./scripts/run-agent-chat.ps1 -SequencePath ./scripts/examples/autonomous-parallel-5-iterations.json -SessionName autonomous-gdd-v1 -MaxSteps 80`
- `pwsh ./scripts/run-agent-chat.ps1 -SequencePath ./scripts/examples/autonomous-parallel-5-iterations.json -SessionName autonomous-gdd-v1 -MaxSteps 80 -Live`
- `pwsh ./scripts/run-agent-chat.ps1 -SequencePath ./scripts/examples/autonomous-parallel-5-iterations.json -SessionName autonomous-gdd-v1 -MaxSteps 80 -Live -Backend cli -CliCommand copilot`

Notes:

- This script runs against a chat completions endpoint and applies your local `.agent.md` instructions as system prompt context.
- It does not invoke VS Code's internal subagent runtime directly.
- Sessions persist to `.agent-sessions/<name>.json` and are replayed as conversation history on later calls.
- `-AllowEdits` lets the called agent return structured local file actions (`write_file`, `append_file`, `replace_text`, `delete_file`) that the script applies inside the repo.
- `-SequencePath` runs a JSON-defined multi-step workflow with conditional branching on `pass`, `fail`, `error`, `defer`, or `repair-required`.
- The included recover sequence shows how to route `explore -> implement -> audit -> recover -> audit` automatically.
- Sequence steps can also define a `parallel` array for fan-out exploration; results are aggregated into `{{parallelResultsJson}}` for downstream merge prompts.
- The autonomous 5-iteration sequence enforces at least five full cycles of `parallel explore -> merge -> implement -> audit` without human interaction, then defers only unresolved human-irreducible blockers.
- `-Live` prints real-time terminal progress per step/agent (`START`, `DONE`, and status lines) during direct and sequence runs.
- `-Backend api|cli` selects direct endpoint calls (`api`, default) or an external CLI backend (`cli`).
- `-CliCommand` sets the executable for CLI backend calls (default: `copilot`).
- `-CliPromptMode stdin|arg` controls whether the composed prompt payload is sent over stdin or as the final CLI argument.
- Override endpoint/model with `-Endpoint` and `-Model` if needed.

## Camera Profile

The camera now uses named profiles in `index.html` under `CAMERA_PROFILES`.
Press `C` (or tap the top-right `C` button) to cycle through all views:

- `CAMERA_PROFILES.classic` for the original chase-camera framing.
- `CAMERA_PROFILES.cute34` for the cute 3/4 perspective (default).
- `CAMERA_PROFILES.diag34` for a stronger diagonal 3/4 framing.
- `CAMERA_PROFILES.fp` for a readability-assisted first-person run view.

## Stability Guardrails

- Adaptive quality uses moving frame-time thresholds and can force low-quality recovery when sustained spikes are detected.
- First-person camera auto-falls back to `cute34` during sustained heavy frame-time spikes.
- If Web Audio cannot recover to running state during gameplay, audio auto-mutes as a fail-safe.
