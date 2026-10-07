import curses
import math
import random
import sys
import time

feed = int(sys.argv[1]) if len(sys.argv) > 1 else 2
rng = random.Random(feed)
glyphs = "0123456789ABCDEF:|+<>"


def monitor(screen):
    curses.curs_set(0)
    screen.nodelay(True)
    started = time.monotonic()
    tick = 0
    while screen.getch() != ord("q"):
        height, width = screen.getmaxyx()
        screen.erase()

        def line(y, text, style=0):
            if 0 <= y < height - 1 and width > 4:
                screen.addnstr(y, 2, text, width - 4, style)

        line(0, f"THE ARCHITECT / FEED {feed:02d}", curses.A_BOLD)
        line(1, "CONSTRUCT 06     SIGNAL LOCKED", curses.A_DIM)
        if feed % 3 == 2:
            rows = max(1, height - 5)
            for x in range(2, width - 2, 2):
                head = (tick // 2 + x * 7 + feed) % (rows + 10)
                for trail in range(9):
                    y = head - trail
                    if 0 <= y < rows:
                        screen.addch(y + 3, x, rng.choice(glyphs),
                                     curses.A_BOLD if trail == 0 else curses.A_DIM)
        elif feed % 3 == 0:
            for row in range(3, height - 3):
                node = row - 2
                pulse = 40 + int(35 * math.sin(tick / 12 + node))
                bar = "=" * max(1, pulse * max(1, width - 25) // 100)
                line(row, f"NODE {node:02d}  [{bar:<{max(1, width - 25)}}] {pulse:02d}%")
        else:
            rows = max(1, height - 6)
            for x in range(2, width - 2):
                wave = math.sin(x / 7 + tick / 6) + math.sin(x / 13 - tick / 9) / 2
                y = 3 + min(rows - 1, max(0, int(rows / 2 + wave * rows / 4)))
                screen.addch(y, x, "." if x % 3 else "+", curses.A_BOLD)
            line(2, "CARRIER / SYNCHRONIZATION TRACE", curses.A_DIM)
        elapsed = int(time.monotonic() - started)
        line(height - 2, f"LIVE SIMULATION  {elapsed // 60:02d}:{elapsed % 60:02d}  Q: EXIT", curses.A_DIM)
        screen.refresh()
        tick += 1
        curses.napms(160)


sys.stdout.write(f"\033]0;Matrix Feed {feed:02d}\007")
sys.stdout.flush()
try:
    curses.wrapper(monitor)
except KeyboardInterrupt:
    pass
finally:
    sys.stdout.write("\033]0;\007")
    sys.stdout.flush()
