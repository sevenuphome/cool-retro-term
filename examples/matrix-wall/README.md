# Matrix Architect terminal wall for macOS

A muted green CRT theme with curved glass, a pale inner rim, a dark cabinet, mechanical key clicks, and an optional CRT hum. Arrange six real terminal windows into a 3×2 wall and run original text animations in the spare windows. The animations simulate code rain, node activity, and signal traces; they do not monitor your computer or connect to a server.

This fork includes the Qt 6 work from [cool-retro-term PR #979](https://github.com/Swordfish90/cool-retro-term/pull/979), pinned at `67281c14f02ebfad7f5f8d7f3ccb179860bd8cbf`, plus these customizations. It uses the companion [qmltermwidget PR #55](https://github.com/Swordfish90/qmltermwidget/pull/55), pinned at `d3e878682fc3873d8b9cfd03778f9a7ac16c271e`. These are the versions used for this setup, not a promise to follow later PR changes. Upstream licenses and attribution remain in the repository. The audio and animations were created for this customization; no movie clips, stills, or audio are included.

## Build the customized app

You need macOS, Xcode Command Line Tools, [Homebrew](https://brew.sh), Git, and Python 3. The customized app was built and run on Apple Silicon with Qt 6.11.2 on 2026-10-07. Intel Macs and other Qt versions have not been verified. There is no notarized binary release for this customization.

```sh
xcode-select --install  # Only if Command Line Tools are not already installed.
brew install qtbase qtdeclarative qtshadertools qt5compat qtmultimedia python
git clone --branch matrix-architect --recurse-submodules https://github.com/sevenuphome/cool-retro-term.git
cd cool-retro-term
```

The widget submodule URL intentionally points to the PR author's fork because the pinned commit may not be available from the upstream repository. For an existing checkout, run `git submodule sync` followed by `git submodule update --init --recursive`.

Build and bundle from the repository root:

```sh
repo="$PWD"
qt_bin="$(brew --prefix qtbase)/bin"
mkdir -p build/dmg
cd build/dmg
"$qt_bin/qmake" CONFIG+=release ../../cool-retro-term.pro
make -j8
mkdir -p cool-retro-term.app/Contents/PlugIns
ditto qmltermwidget/QMLTermWidget cool-retro-term.app/Contents/PlugIns/QMLTermWidget
"$qt_bin/macdeployqt" cool-retro-term.app \
  -qmldir="$repo/app/qml" \
  -qmlimport="$repo/build/dmg/qmltermwidget"
codesign --force --deep --sign - cool-retro-term.app
codesign --verify --deep --strict cool-retro-term.app
open cool-retro-term.app
cd "$repo"
```

These commands bundle a local development app; ad-hoc signing is not Apple notarization. The installed development build passed signature/dependency checks, but fresh bundling on a different Mac may need Qt deployment troubleshooting. If you already have cool-retro-term running, finish its sessions and quit it before switching builds. Once satisfied, copy `build/dmg/cool-retro-term.app` to Applications using Finder, keeping your previous app if you want a rollback.

## Apply the look and sound

1. Open **Edit → Settings**, then the **General** tab's **Profile** section.
2. Save your current appearance under a name such as **Before Matrix**.
3. Click **Import**, choose [`Matrix Architect.json`](Matrix%20Architect.json), then select it and click **Load**. It is also available from the **Profiles** menu afterward.
4. Open **Edit → Sound settings…**, or right-click inside the terminal and choose **Sound settings…**.
5. Enable **Mechanical typing sound** and adjust its volume. Separately enable **CRT hum and hiss** and set its volume. Changes save immediately for all windows. A quiet starting point is typing at **7%**, with hum off (or **13%** when enabled).

The custom rim, sound dialog, and frameless window require this fork. Importing the profile into another build does not install those code changes. Sound preferences are independent of the visual profile. Drag the upper dark bezel to move a window, resize from its edges, and use **Command-W** to close it. All profiles in this build use frameless windows.

## Arrange six windows

Open exactly six terminal **windows** using **File → New Window**, and close any settings dialogs. Keep your working session roughly at the top-left and the others roughly in their desired two rows. The script sorts the three upper windows left-to-right, then the three lower windows. It moves and resizes windows only: it never types commands, closes sessions, or restarts the app.

From the repository root, list your displays:

```sh
osascript examples/matrix-wall/arrange-six.applescript
```

Choose the number printed for your desired display. For example, if it is display **3**:

```sh
# Preview the destination for every window first.
osascript examples/matrix-wall/arrange-six.applescript 3

# Apply that arrangement and verify the resulting positions and sizes.
osascript examples/matrix-wall/arrange-six.applescript 3 --apply
```

macOS may ask for permission to control System Events. Allow the terminal application you run this from in **System Settings → Privacy & Security → Accessibility**, and approve its System Events automation prompt if shown. The script calculates display geometry automatically, including displays above or beside the main screen, Retina scaling, the Dock, and at least 30 points of top clearance for the menu bar. Display numbers can change after reconnecting monitors, so list them again when needed.

Avoid switching windows during the few seconds the script runs, because macOS can reorder its window list. The layout fills the chosen display with a 3×2 grid. It requires all six app windows to be ordinary, non-minimized terminal windows, on the current desktop/Space. On a very small display, macOS/Qt may enforce a minimum window size; the script reports a geometry error rather than claiming success. Move the windows manually or use a larger display in that case.

## Put animations in the five spare terminals

Leave the top-left terminal for your real work. In each other idle shell, first `cd` to this cloned repository, then run the corresponding command:

| Position | Command | Display |
| --- | --- | --- |
| Top-middle | `python3 examples/matrix-wall/matrix-wall.py 2` | Code rain |
| Top-right | `python3 examples/matrix-wall/matrix-wall.py 3` | Node activity |
| Bottom-left | `python3 examples/matrix-wall/matrix-wall.py 4` | Signal trace |
| Bottom-middle | `python3 examples/matrix-wall/matrix-wall.py 5` | Code rain |
| Bottom-right | `python3 examples/matrix-wall/matrix-wall.py 6` | Node activity |

The Python script uses only the standard library and runs until you press lowercase **q** or **Control-C** in that window. It returns to the shell, restores the terminal, and clears the demo's window title. You can resize the window while it runs. It can also run in an ordinary terminal, but the CRT effects come from cool-retro-term. Use a normal-sized terminal window; extremely tiny terminal grids are not supported.

## A reusable prompt for an assistant

```text
Use the Matrix Architect setup in this repository's examples/matrix-wall/README.md.
Inspect my cool-retro-term windows and displays. Keep my active work session alive.
Use AppleScript/System Events to arrange exactly six terminal windows into a 3×2
grid on the display I select, with my working terminal at the top-left. Preview
the layout first and check the final geometry. Do not restart the app or close
any sessions. Apply the Matrix Architect profile if needed. In the five other
windows, inspect each one to confirm it is an idle shell before typing the
documented Python feed command for that position. Never type into a running
agent or another active program. Verify all five feeds are running and tell me
how to stop them. Keep my existing sound settings unless I ask to change them.
```

## What was verified

On 2026-10-07, the customized app rendered the green CRT profile and frameless windows on an Apple Silicon Mac. The sound menu and context-menu routes, independent toggles/volume persistence, keyboard input, native resize, and Command-W were checked through the native UI. All five Python feeds rendered in a six-window wall while the existing Claude session continued running. The existing app/widget drop tests had 9 passing cases; this does not establish manual Finder drag-and-drop behavior. See [project knowledge](../../.context/compound.md) for retained implementation pointers.
