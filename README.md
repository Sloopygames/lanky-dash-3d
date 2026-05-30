# Lanky Dash

A 3D endless **size-runner**. You auto-run down a three-lane track as a scrawny
stick figure. Steer through math gates to change your **POWER** — `+5` and `×2`
make you taller and wider, `−3` and `÷2` shrink you. Dodge spinning saws,
swinging hammers and brick walls (they knock your power down). Every stretch of
track ends in a **boss**: charge it, and if your POWER beats the number floating
over its head you smash clean through in a shower of debris and keep going,
faster. Too small? It swats you and the run is over.

The whole game is the satisfaction of turning a twig into a giant and watching
bosses explode.

## Controls

- **Steer:** `←` / `→` or `A` / `D` — or drag / tap the left or right side of the
  screen (swipe on mobile).
- **Start / Retry:** `Space`, `Enter`, click, or tap.
- **Pause:** `P` or `Esc`.
- **Camera:** `C` or the `C` button (top-right) toggles Classic/Cute 3/4 views.
- **Mute:** `M` or the speaker button (top-right).
- **Fullscreen:** the expand button (top-right).

## Features

- Procedural endless track that speeds up the further you get.
- `+`, `×`, `−`, `÷` gates with real route-choice tension.
- Auto-smash bosses with escalating POWER thresholds.
- Squash-and-stretch growth, particle bursts, screen shake, hit-pause and slow-mo.
- Procedural Web Audio music and SFX with a mute toggle.
- Desktop keyboard + mouse and full mobile touch support.
- Best score saved locally.

## Tech

Single self-contained `index.html`. Vanilla JavaScript with **Three.js**
(loaded from a CDN importmap) for 3D rendering and the **Web Audio API** for
procedural sound. No build step, no backend, no frameworks.

## Camera Profile

The camera now uses named profiles in `index.html` under `CAMERA_PROFILES`.
Press `C` (or tap the top-right `C` button) to cycle through all views:

- `CAMERA_PROFILES.classic` for the original chase-camera framing.
- `CAMERA_PROFILES.cute34` for the cute 3/4 perspective (default).
- `CAMERA_PROFILES.diag34` for a stronger diagonal 3/4 framing.
