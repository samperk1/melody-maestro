# Melody Maestro: Development Status & Todo List

## What We Have Done:
- **Core Engine:** Built in Godot 4 with MIDI and Microphone input support.
- **Input System:** 
    - Safe numeric MIDI handling and on-screen keyboard mouse support.
    - **Computer Keyboard Input:** White keys (Home row: A,S,D,F,G,H,J,K,L,;) and Black keys (QWERTY: W,E,T,Y,U,O,P).
    - **Mic Calibration:** Fully implemented FFT pitch detection for real-time piano analysis.
    - **Startup Stability Fix:** Added custom `linear_to_db` helper to prevent potential FFT-related crashes.
- **Visuals:** 
    - Animated "Tuxedo Guy" pianist on the start screen.
    - Falling "Synthesia-style" balloons and monsters that line up with keys.
    - **Monster Readability:** Enhanced monster note labels with larger font sizes and thick outlines.
    - On-screen musical staff showing upcoming notes.
    - "♫" projectiles that fly from keys to pop targets.
    - Menacing monster transformations (glowing eyes, jittering, slime explosions).
    - Atmospheric background shift (Blue-Grey to Deep Crimson).
- **Gameplay Mechanics:**
    - Progressive level system with a song library.
    - **3-Life / 3-Strike System:** Wrong keys cause strikes; 3 strikes lose a life; 0 lives is Game Over.
    - **Level 30+ Chord Mode:** Multi-note challenges.
    - **Tempo Scaling:** Game speeds up as you progress.
    - **Balloon Party:** High-intensity celebration screen after level clears.
- **Audio:** Custom sound engine for piano beeps, pops, drums, and bass backing tracks.
- **Persistence:** High score saving and level progress tracking.
- **Distribution:** Created a project ZIP (v2) for testing.

## Still Need To Do:
1. **Flatpak Packaging:** Finalize the `flatpak-builder` manifest and create the distributable Linux bundle.
2. **GitHub Repo:** Finish pushing the code to a remote GitHub repository once `gh` is configured.
3. **Advanced Modes:** Implement "Monster Defense" (zombies approaching from the distance) as a distinct gameplay mode.
4. **Music Content:** Expand the song library with more pop, jazz, blues, and classical tracks.
5. **Polish:** Add more dialogue for "Maestro the Muse" and refine the slime particle physics.

**Status:** Ready for Flatpak distribution and further testing.
