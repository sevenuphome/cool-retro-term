# Project knowledge

## Decisions and constraints
- Matrix Architect fork preserves PR #979 at `67281c14f02ebfad7f5f8d7f3ccb179860bd8cbf` and widget PR #55 at `d3e878682fc3873d8b9cfd03778f9a7ac16c271e`. Keep the widget submodule on the PR author's URL; upstream may not contain the commit. User requested publication under `sevenuphome/cool-retro-term`, 2026-10-07.
- Preserve active terminal sessions when adjusting layout; do not restart the app to arrange windows. Appearance and sound settings are independent. No movie media is included.

## Completed and verified
- Native arm64 build/install on macOS with Qt 6.11.2, 2026-10-07. Existing drop-area/widget tests: 9 passed; signature/dependency audit passed. Manual Finder drag behavior remains unverified.
- Matrix profile/rim: `examples/matrix-wall/Matrix Architect.json`, `app/qml/TerminalFrame.qml`, `app/shaders/terminal_frame.frag`; native rendered appearance verified, 2026-10-07.
- Typing and CRT hum: original WAVs in `app/qml/sounds`, effects in `main.qml`, key trigger in `PreprocessedTerminal.qml`, saved independent toggles/volumes in `ApplicationSettings.qml`. Menu/context-menu dialog in `TerminalWindow.qml` and `menus/`; UI routes and saved values verified, 2026-10-07. No independent speaker recording was made.
- Frameless windows with top-bezel dragging, edge resize, Command-W; native resize and close verified, 2026-10-07. Five `matrix-wall.py` feeds rendered in a 3×2 wall while the original working session continued.

- Portable `arrange-six.applescript` applied and verified the existing six-window layout at 640×525 points per window, 2026-10-07; display listing/preview and Python compilation passed. PR #979 GitHub head rechecked and still matches the pinned base.

## Working setup
- Follow `examples/matrix-wall/README.md` for build, profile import, sound settings, layout script, feed commands, and reusable assistant prompt. New users must import the profile; personal settings databases are not distributed.
- Qt requires qtbase, qtdeclarative, qtshadertools, qt5compat, and qtmultimedia. Build in `build/dmg`; bundle QMLTermWidget with its exact capitalized module directory and pass its import directory to macdeployqt.

## Pitfalls and solutions
- Qt window geometry setters are asynchronous: set positions, wait 0.4s, set sizes, wait, reapply positions, wait, verify. See `examples/matrix-wall/arrange-six.applescript`.
- On macOS, frameless windows on displays above the main display may reject computer-tool mouse clicks. User-authorized System Events AXRaise followed by keyboard input worked; inspect the target before typing. App-window enumeration order changes when raised.
- Use Q or Control-C to exit demo feeds. Escape is intentionally ignored because macOS window-switch shortcuts can send escape sequences.
- macdeployqt warnings do not establish a valid bundle; check codesign and bundled dependencies. Rebuilding an executable inside an already bundled app can restore Homebrew framework paths: rerun deployment before signing.
- System Events may resolve saved window references by changing terminal titles. The layout script stores window indices, does not raise windows while arranging, and re-resolves each window inside the process tell block. Avoid switching windows while it runs.
