# Melody Maestro — Developer Notes & Roadmap

## Architecture Overview

The game is a single Godot 4 project using GDScript throughout. There are two autoloads (globals) and a small set of scenes:

| Autoload | Role |
|---|---|
| `GameManager` | Player name, score, level index, song library (30 songs), top-3 leaderboard, save/load |
| `SoundManager` | Procedural audio engine — generates all sounds at runtime (no audio files needed) |
| `InputHandler` | Routes MIDI events, keyboard presses, and microphone pitch data into unified `note_on` / `note_off` signals |

Scene flow: `welcome_screen.tscn` → `main_game.tscn` (reloaded on restart or level clear).

---

## What Is Done

### Input
- **MIDI** — full Note On / Note Off handling, velocity-aware, works on Linux via `OS.open_midi_inputs()`
- **Computer Keyboard** — two-octave piano layout (home row = white keys, QWERTY row = black keys), C4–E5
- **Microphone / Acoustic** — real-time FFT via Godot's `AudioEffectSpectrumAnalyzerInstance`; samples 27 Hz–4 kHz, maps dominant frequency to nearest MIDI note; custom `linear_to_db` helper avoids crash on zero-magnitude frames
- **Keyboard sizes** — 25 / 49 / 61 / 88 keys; key x-positions used to aim projectiles and spawn balloons above matching keys

### Gameplay
- Balloon spawner driven by a Timer, pulls notes from the current song's array
- Monster probability scales from 0% at level 1 to 100% at level 20
- Tempo scales: `90 + level * 5` px/s balloon speed
- 3-life / 3-strike system; wrong note in celebration mode ignored
- Groove system: streak ≥ 4 unlocks drum beat, streak ≥ 8 unlocks bass pulse
- Level 30+ procedural generator: ramps from single notes → two-note intervals → three-note chords over increasing difficulty parameter
- Pause system: `get_tree().paused = true` freezes all game nodes; pause overlay uses `PROCESS_MODE_ALWAYS` to stay interactive; Escape key toggles

### Visuals
- Monsters drawn entirely in `_draw()` — horns, body, arms with claws, walking legs, angry brows, teeth; colour lerps green → crimson over 30 levels; eye colour shifts yellow → red at level 12
- Monster note labels: yellow text, font size 30, outline size 12, dark semi-transparent backdrop with yellow border
- On-screen piano keys: font size 14 (white keys) / 11 (black keys)
- Start screen pianist: full tuxedo character in `_draw()` — top hat, satin lapels, red bow tie, pocket square, alternating playing hands animated with tweens
- Background atmosphere: `ColorRect` colour waves via `sin()` on multiple frequencies, base colour lerps blue-grey → deep crimson by level 30
- Sky manager handles clouds / atmospheric effects behind gameplay
- Note projectile: `♫` symbol flies from key to balloon/monster on correct hit
- Level-clear panel: shows song cleared, Continue / Try Again buttons
- Pause panel: centred overlay, Resume and Quit to Menu buttons

### Audio
- All audio generated procedurally at startup — no bundled audio files
- Piano note: sine + octave harmonic with exponential decay envelope
- Pop: noise burst with decay
- Maestro voice: tone + harmonics + noise with sine envelope
- Drum beat: frequency-swept sine (kick)
- Bass pulse: 55 Hz sine with exponential decay
- `play_note(midi_note, vol_db)` — optional volume parameter used by menu music (-22 dB)
- Menu music: 32-note jazz melody loops on start screen using the same procedural piano tone

### Persistence
- Save file: `user://save_game.dat` (JSON)
- Stores top-3 leaderboard as `[{name, score}, ...]` sorted descending
- Migrates old single-entry `high_score` / `high_score_player` format automatically on first load
- `GameManager.save_game()` called on level clear, restart, and exit

### Song Library (30 tracks)
| Tier | Levels | Examples |
|---|---|---|
| Beginner | 1–5 | Mary Had a Little Lamb, Twinkle Twinkle, Hot Cross Buns |
| Easy | 6–10 | Fly Me to the Moon (Jazz), Jingle Bells, Havana, Shape of You |
| Intermediate | 11–15 | Amazing Grace, Ode to Joy, Minuet in G, Fur Elise |
| Advanced | 16–20 | Moonlight Sonata, Turkish March, Canon in D, Spring (Vivaldi) |
| Expert | 21–25 | Imperial March, Super Mario Bros, Tetris, Hedwig's Theme |
| Master | 26–30 | Game of Thrones, Beethoven's 5th, Flight of the Bumblebee |

### Distribution
- `org.melodymaestro.Game.yaml` Flatpak manifest created; build with `flatpak-builder --force-clean build-dir org.melodymaestro.Game.yaml`

---

## Still To Do

1. **Flatpak finalisation** — test the built bundle end-to-end; verify MIDI and mic permissions in the sandbox
2. **Sound quality** — the procedural piano tone is functional but thin; consider adding a sampled piano soundfont (SF2) via GDNative or baking short WAV samples into the project
3. **More songs** — expand the library with more pop, jazz, blues, and classical; add difficulty metadata so songs can be sorted/filtered
4. **Settings screen** — volume slider, key remapping UI, toggle for menu music
5. **Monster polish** — more distinct monster types per difficulty tier; death animation variety
6. **Maestro dialogue** — expand the Maestro character speech beyond "welcome" / "missed" / "good_job"
7. **Accessibility** — colour-blind friendly note colours; larger UI scaling option
8. **High score names** — allow players to enter initials on a game-over screen rather than using the name from the start screen
9. **Mobile / gamepad** — touch input and controller support for non-keyboard players

---

## Known Issues / Watch Out For

- **Mic input** requires a `Record` audio bus with a `AudioEffectSpectrumAnalyzer` effect added in the Godot Audio settings. If this bus is missing the analyzer silently does nothing (no crash, just no mic detection).
- **MIDI on non-Linux** — `OS.open_midi_inputs()` is gated on `OS.has_feature("midi")` which may not report correctly on all export targets; test on Windows/Mac exports if targeting those platforms.
- **Pause + scene change** — `get_tree().paused` is reset to `false` in `_on_exit_pressed()` before changing scenes; if adding any other scene-change path, make sure to do the same or the new scene will load frozen.
- **Chord mode (level 30+)** — the procedural generator uses `randf()` so sequences are not reproducible between runs; if adding a replay or daily-challenge feature, seed the RNG.

---

## Changelog

### Latest
- Added **pause system** (Escape key + Pause button); pause overlay with Resume and Quit to Menu
- **Top-3 leaderboard** replacing single high score; auto-migrates old save format
- **Start screen background music** — 32-note jazz melody loops quietly (-22 dB)
- **Tuxedo pianist redesign** — fully redrawn in `_draw()` with top hat, lapels, bow tie, animated playing hands
- **Monster note label readability** — yellow text, font size 30, outline 12, dark backdrop
- **Piano key font size** — increased from 10/8 px to 14/11 px (white/black keys)
- **Computer keyboard input** — full two-octave layout mapped to home row + QWERTY row

### Earlier
- 30-song library across 6 difficulty tiers
- Monster mode with procedural draw, level-scaling colour/size/speed
- Groove system (drum + bass unlocked by streak)
- 3-life / 3-strike system
- Level 30+ chord mode procedural generator
- Flatpak manifest
- Mic FFT pitch detection
- Projectile note animations
- Musical staff display
- Atmospheric background shift
