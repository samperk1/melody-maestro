# Melody Maestro

A piano learning game built with Godot 4.

## Features
- **MIDI Input:** Support for external MIDI keyboards.
- **Audio Input:** Acoustic piano detection using real-time pitch analysis (Beta).
- **Multiple Keyboard Sizes:** 25, 49, 61, 88 keys support.
- **Balloons Mode:** Pop balloons with the correct notes.
- **Monster Mode:** Defend against zombies by playing notes.
- **Dynamic Music:** Experience the "Groove" with backing tracks.

## How to Play
1. Enter your name and select your input method.
2. Select the number of keys on your keyboard.
3. Hit the notes as they appear on the screen!

## Development
- **Engine:** Godot 4.x
- **Language:** GDScript
- **Packaging:** Flatpak

## Distribution
To build the Flatpak:
```bash
flatpak-builder --force-clean build-dir org.melodymaestro.Game.yaml
```
