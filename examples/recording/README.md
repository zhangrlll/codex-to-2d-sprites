# Godot capture and verification for this case study

**English** | [简体中文](README.zh-CN.md)

This directory documents how the showcase media was made. The video captures a real Godot 4.6 scene and its character controller. A script calls `Input.action_press()` and `Input.action_release()` to simulate controls, while Movie Maker records the output. The character's position is reset between labeled takes.

- `record_github_showcase.gd`: shows 8 directions × 5 actions, then four combinations of walking/running into a roll/jump.
- `capture_github_gallery.gd`: renders frames for eight-direction GIFs using the same character and shader, preserving head stabilization and idle breathing.
- `verification.json`: video properties, coverage of 40 combinations, source poses used by moving transitions, GIF frame counts, the original image's SHA-256, and chapter timestamps.

These scripts are **capture examples for this particular project**. They depend on `scenes/main.tscn`, `scenes/player.tscn`, and the project's character/sprite interfaces. The complete character project and model are not included in the skill repository. Adapt the nodes and input actions to use them with another project.

## Record a project with the same structure

Copy the two `.gd` files into the Godot project's `tests/` directory, replace `<project>` below, and run in an environment with graphics rendering support:

```sh
godot --path <project> --fixed-fps 30 --write-movie ../ShowcaseRecording/godot-showcase.avi --script tests/record_github_showcase.gd
godot --path <project> --script tests/capture_github_gallery.gd
```

Create a `ShowcaseRecording` directory alongside the project first. Let the script exit normally so the AVI is finalized. Video resolution depends on the actual rendering window; this recording is **1152 × 720, 30 FPS, 3154 frames, 105.13 seconds**.

Convert it to an MP4 for browser playback:

```sh
ffmpeg -i godot-showcase.avi -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -movflags +faststart -an godot-eight-directions.mp4
```

Convert each action's PNG sequence to a GIF, for example idle:

```sh
ffmpeg -framerate 30 -i gallery/idle/%03d.png -filter_complex "[0:v]split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=sierra2_4a:diff_mode=rectangle" -loop 0 idle-8-directions.gif
```

GIF timing uses hundredths of a second, so 30 FPS is approximated with 30/40 ms delays. This example preserves the overall action cycle timing. The GIF background is for viewing; production assets use transparent PNGs and sprite sheets.

## What was checked

1. All 40 action/direction combinations have actual recorded frames. Walk, run, roll, and jump cover all 12 source poses.
2. Each idle direction covers a full breathing cycle, with the chest deformation parameter spanning approximately 0–2.4 pixels.
3. Walk/run into roll uses source poses 2–8; walk/run into jump uses 3–8 (zero-based). Each returns to the corresponding movement state.
4. Review includes recording logs, captured video frames, and eight-direction previews, along with checks of GIF frame counts and durations, MP4 encoding, and the complete video frame count.
5. The supplied GPT image was uploaded without modification; its SHA-256 is included in the verification record.

Numerical and coverage checks support visual review; they do not prove the artistic quality of every frame. The showcase presents the final Godot render, including runtime shader corrections for idle breathing and head stability.

Reference: [Godot's official Movie Maker documentation](https://docs.godotengine.org/en/4.6/tutorials/animation/creating_movies.html).
