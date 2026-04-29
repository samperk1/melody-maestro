# Melody Maestro — Developer Notes & Roadmap

## Architecture Overview

The game is a single Godot 4 project using GDScript throughout. There are two autoloads (globals) and a small set of scenes:

| Autoload | Role |
|---|---|
| `GameManager` | Player name, score, level index, song library (30 songs), top-3 leaderboard, save/load |
| `SoundManager` | Procedural audio engine — generates all sounds at runtime (no audio files needed) |
| `InputHandler` | Routes MIDI events, keyboard presses, and microphone pitch data into unified `note_on` / `note_off` signals |

Scene flow: `main_game.tscn` is the permanent main scene — it never changes. The welcome screen loads as a `CanvasLayer` overlay (layer=100) on startup and is hidden (not freed) when the player starts a game, then re-shown on exit. This avoids Godot 4.6.2's AT-SPI idle-loop freeze that occurs whenever nodes exit the scene tree on Linux.

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
- **Linux AppImage** — `builds/linux/MelodyMaestro-1.0.0-x86_64.AppImage` (27 MB, tested on Manjaro). Built by `build_appimage.sh` which exports via Godot headless then wraps binary in a shell script that suppresses the Godot 4.6.2 AT-SPI crash (`AT_SPI_BUS_ADDRESS=""`, `NO_AT_BRIDGE=1`, `GNOME_ACCESSIBILITY=0`, `unset DRI_PRIME`). Two harmless disconnect errors always appear in terminal — unfixable without patching the engine.
- **Windows exe** — `builds/windows/MelodyMaestro.exe` (100 MB). Run directly, no install needed.
- **GitHub release v1.0.0** — both assets published at github.com/samperk1/melody-maestro/releases
- `org.melodymaestro.Game.yaml` Flatpak manifest exists but is untested
- **Web / GitHub Pages** — `docs/coi-serviceworker.js` is ready; export the game from Godot to `docs/index.html`, add `<script src="coi-serviceworker.js"></script>` to that file, then enable GitHub Pages from the `docs/` folder. Full guide: [`DEPLOY.md`](DEPLOY.md)

---

## Bug Fixes Applied

| Fix | Files | Detail |
|---|---|---|
| Staff note mismatch — wrong timing | `main_game.gd` | Staff now updates to the current spawning note at the start of `_spawn_next_balloon()`, not the next note after spawning |
| Staff note mismatch — wrong position | `music_staff.gd` | Replaced chromatic half-step formula with correct diatonic treble-clef mapping anchored to E4 on the bottom staff line; added ledger lines and note name label |

---

## Still To Do

### Android Port (planned, in order)

Full plan agreed. Build needs Android SDK + a capable machine — may need the big desktop PC for the APK build step.

**Phase 1 — Export setup** (one-time, ~2–3 hours)
- Download Godot 4 Android export templates (Editor → Manage Export Templates)
- Install Android Studio / SDK, point Godot Editor Settings to SDK path
- Generate signing keystore: `keytool -genkey -v -keystore melody-maestro.keystore -alias melody-maestro -keyalg RSA -keysize 2048 -validity 10000`
- Add Android preset in Godot: package `com.samperk1.melodymaestro`, link keystore, add RECORD_AUDIO permission
- Export `.apk` for sideload testing (free — no Play Store account needed)

**Phase 2 — Input modes on Android** (~3–4 hours)
- On Android, show only 3 input options: **MIDI Keyboard**, **Touch Keyboard**, **Tap Balloons**
- Remove Computer Keyboard and Microphone from the option list on mobile (`OS.get_name() in ["Android", "iOS"]`)
- Hide the keyboard-size dropdown on mobile (irrelevant for touch/tap modes)
- **Touch keyboard:** make keys bigger (~65 px wide vs 25 px), show only 13 notes (1 octave) centred on song's range; add `InputEventScreenTouch` alongside `InputEventMouseButton` in `piano_keyboard.gd _on_key_input()`; turn off "Emulate Mouse From Touch" in Project Settings when touch keyboard is selected
- **Tap balloon mode:** in `balloon.gd _input()`, detect `InputEventScreenTouch` on the balloon's area and emit `InputHandler.note_on(target_note)` — existing scoring/strike logic unchanged

**Phase 3 — Mobile game mechanic** (~2–3 hours)
- No chords on mobile: level 30+ procedural generator returns single notes only when on Android/iOS
- Speed escalates instead of chord complexity: add `(current_level - 30) * 10.0` extra px/s beyond level 30
- In tap mode: spawner waits until `active_balloons.size() == 0` before spawning next — true one-at-a-time
- Empty-space taps do not count as strikes in tap mode (accidental touches); tapping the wrong balloon still does

**Phase 4 — Layout & UI** (~2–3 hours)
- Lock orientation to landscape in Android export preset
- Bump button minimum size to 80 px tall for finger comfort
- Increase leaderboard/score font size on mobile

**Phase 5 — Device testing** (variable)
- Sideload APK via `adb install` or copy to phone
- Test: MIDI via USB-C OTG, touch keyboard multi-touch, tap mode strike logic, pause, exit→welcome, leaderboard save

**Phase 6 — Google Play Store** (1 day + 3–7 day review, $25 one-time)
- Signed `.aab` from Godot
- Store listing: name, description, screenshots (phone + tablet), icon (512×512)
- Privacy policy page (GitHub Pages sufficient — state no data leaves device)
- Submit to Internal Testing first, then promote to Production

### Other TODOs
1. **Sound quality** — procedural piano tone is thin; consider SF2 soundfont or baked WAVs
2. **Settings screen** — volume slider, key remapping, menu music toggle
3. **More songs** — expand library; add difficulty metadata
4. **Monster polish** — more distinct types per tier, more death animations
5. **Maestro dialogue** — expand beyond "welcome" / "missed" / "good_job"
6. **Accessibility** — colour-blind note colours, UI scaling option
7. **High score name entry** — let player enter name on game-over screen
8. **Flatpak** — `org.melodymaestro.Game.yaml` exists but untested end-to-end

---

## Known Issues / Watch Out For

- **Mic input** requires a `Record` audio bus with a `AudioEffectSpectrumAnalyzer` effect added in the Godot Audio settings. If this bus is missing the analyzer silently does nothing (no crash, just no mic detection).
- **MIDI on non-Linux** — `OS.open_midi_inputs()` is gated on `OS.has_feature("midi")` which may not report correctly on all export targets; test on Windows/Mac exports if targeting those platforms.
- **Pause + scene change** — `get_tree().paused` is reset to `false` in `_on_exit_pressed()` before changing scenes; if adding any other scene-change path, make sure to do the same or the new scene will load frozen.
- **Chord mode (level 30+)** — the procedural generator uses `randf()` so sequences are not reproducible between runs; if adding a replay or daily-challenge feature, seed the RNG.

---

## Changelog

### v1.0.0 (released 2026-04-18)
- Linux AppImage working end-to-end on Manjaro; published to GitHub releases
- Windows exe published alongside AppImage
- Fixed Godot 4.6.2 AT-SPI idle-loop freeze: eliminated all scene transitions, replaced with CanvasLayer overlay pattern; hide() instead of queue_free() throughout
- AT-SPI per-frame slot error suppressed via env vars in AppRun + binary wrapper
- Git attribution updated: Sam Perkins (samperk1@hotmail.com)

### Earlier
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
