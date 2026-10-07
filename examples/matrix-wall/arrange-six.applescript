use framework "AppKit"
use scripting additions

on run argv
    set screens to current application's NSScreen's screens()
    set screenCount to screens's |count|() as integer
    set displayReport to "Displays (macOS points):" & linefeed
    repeat with i from 1 to screenCount
        set scr to screens's objectAtIndex:(i - 1)
        set displayReport to displayReport & i & ": " & (scr's localizedName() as text) & linefeed
    end repeat
    if (count of argv) is 0 then return displayReport & "Usage: osascript arrange-six.applescript DISPLAY_NUMBER [--apply]"
    set displayNumber to item 1 of argv as integer
    if displayNumber < 1 or displayNumber > screenCount then error "Display number is out of range."
    set shouldApply to false
    if (count of argv) > 1 then
        if item 2 of argv is not "--apply" then error "Expected --apply or no second argument."
        set shouldApply to true
    end if
    set primaryFrame to (screens's objectAtIndex:0)'s frame()
    set primaryHeight to item 2 of item 2 of primaryFrame
    set targetScreen to screens's objectAtIndex:(displayNumber - 1)
    set visibleFrame to targetScreen's visibleFrame()
    set fullFrame to targetScreen's frame()
    set topInset to (item 2 of item 1 of fullFrame) + (item 2 of item 2 of fullFrame) - (item 2 of item 1 of visibleFrame) - (item 2 of item 2 of visibleFrame)
    set extraTopInset to 0
    if topInset < 30 then set extraTopInset to 30 - topInset
    set originX to round (item 1 of item 1 of visibleFrame) rounding down
    set originY to round (primaryHeight - (item 2 of item 1 of visibleFrame) - (item 2 of item 2 of visibleFrame) + extraTopInset) rounding down
    set cellWidth to round ((item 1 of item 2 of visibleFrame) / 3) rounding down
    set cellHeight to round (((item 2 of item 2 of visibleFrame) - extraTopInset) / 2) rounding down
    set orderedWindows to {}
    tell application "System Events"
        if not (exists process "cool-retro-term") then error "Open cool-retro-term and exactly six terminal windows first."
        tell process "cool-retro-term"
            if (count of windows) is not 6 then error "Exactly six windows are required. Close settings dialogs and create six terminal windows."
            repeat with windowIndex from 1 to 6
                set p to position of window windowIndex
                set end of orderedWindows to {windowIndex as integer, item 1 of p, item 2 of p}
            end repeat
        end tell
    end tell
    -- Sort into two rows by current position, then left-to-right within each row.
    repeat with i from 1 to 5
        repeat with j from (i + 1) to 6
            if item 3 of item j of orderedWindows < item 3 of item i of orderedWindows then
                set tmp to item i of orderedWindows
                set item i of orderedWindows to item j of orderedWindows
                set item j of orderedWindows to tmp
            end if
        end repeat
    end repeat
    repeat with firstIndex in {1, 4}
        repeat with i from firstIndex to (firstIndex + 1)
            repeat with j from (i + 1) to (firstIndex + 2)
                if item 2 of item j of orderedWindows < item 2 of item i of orderedWindows then
                    set tmp to item i of orderedWindows
                    set item i of orderedWindows to item j of orderedWindows
                    set item j of orderedWindows to tmp
                end if
            end repeat
        end repeat
    end repeat
    set targets to {}
    set reportText to (targetScreen's localizedName() as text) & ": " & cellWidth & " x " & cellHeight & " points per terminal" & linefeed
    repeat with i from 1 to 6
        set targetPosition to {originX + ((i - 1) mod 3) * cellWidth, originY + ((i - 1) div 3) * cellHeight}
        set end of targets to targetPosition
        tell application "System Events" to tell process "cool-retro-term" to set windowTitle to name of window (item 1 of item i of orderedWindows)
        set reportText to reportText & i & ": " & windowTitle & " -> " & item 1 of targetPosition & "," & item 2 of targetPosition & linefeed
    end repeat
    if not shouldApply then return "PREVIEW ONLY" & linefeed & reportText
    tell application "System Events"
      tell process "cool-retro-term"
        repeat with i from 1 to 6
            set w to window (item 1 of item i of orderedWindows)
            set position of w to item i of targets
        end repeat
        delay 0.4
        repeat with i from 1 to 6
            set w to window (item 1 of item i of orderedWindows)
            set size of w to {cellWidth, cellHeight}
        end repeat
        delay 0.4
        repeat with i from 1 to 6
            set w to window (item 1 of item i of orderedWindows)
            set position of w to item i of targets
        end repeat
        delay 0.4
        repeat with i from 1 to 6
            set w to window (item 1 of item i of orderedWindows)
            if position of w is not item i of targets or size of w is not {cellWidth, cellHeight} then error "macOS did not accept the requested geometry. Check the windows and retry."
        end repeat
      end tell
    end tell
    return "APPLIED AND VERIFIED" & linefeed & reportText
end run
