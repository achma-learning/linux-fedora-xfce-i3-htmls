# Status — read this first in any new session

## Decision, final
i3 (with XFCE components, "Route B") is the daily driver. XFCE stock stays as the
login-screen fallback, untouched. KDE Plasma was evaluated and explicitly rejected as a
base — not attempted, no packages installed for it.

## What is APPLIED and confirmed working
- i3 4.25.1, XFCE components (xfsettingsd, xfce4-panel, xfce4-power-manager,
  thunar --daemon, xfce-polkit) launched via `exec` (not exec_always) in i3 config
- picom running: rounded corners, shadows, fading. Panel/dock distinguished by y=0 vs
  y!=0 (both are 1600px full-width, width alone can't tell them apart)
- rofi 2.0 as launcher + window switcher; power menu (scripts/powermenu.sh) replaced the
  old i3 exit mode, bound to $mod+Shift+e
- gaps inner 8, smart_gaps on, default_floating_border pixel 0
- Anki tiles normally (float rule deliberately NOT added — main window should tile)
- Animations (picom 13, all four states verified from picom's debug log on 2026-08-22):
  open/close, workspace switch (light scale+fade both ways), focus change (unfocused normal
  windows sit at 0.92 and the transition is animated), and minimize (shrink + fall to the
  bottom of the screen). $mod+m / $mod+Shift+m now go through scripts/minimize.sh and
  scripts/unminimize.sh, which tag the window with _I3_MINIMIZED so picom can tell a
  minimize apart from a workspace switch — both reach it as the same `hide` trigger.
- panel-2 restored after it was accidentally deleted: scripts/restore-panel-2.sh
- All committed to git in this repo; ROLLBACK.md / undo.sh tested and working

## Still open, in priority order
1. Bottom panel (panel-2) is full-width and flush to the screen edge, so picom's rounded
   corners are clipped off-screen and invisible. **Now diagnosed, and it is not an xfconf
   problem — i3 is the one placing it.** Measured 2026-08-22 (xfce4-panel 4.20.7, i3 4.25.1):
     * `/panels/panel-2/length` = 30 with `length-adjust` true AND false, across a full
       `xfce4-panel -q` + restart: the window stays 1600x60 at y=840 every time (measured
       from i3's own tree and by capturing the window with `import -window <id>`).
     * `/panels/panel-2/position` = `p=0;x=800;y=860` is ignored the same way.
     * `i3-msg '[id=<dock>] floating enable'` returns success but the con stays
       `floating: auto_off` — i3 refuses to float a dock client.
   i3 pins dock-type windows to the top or bottom edge and stretches them to the output
   width, and nothing in xfconf overrides that. So a centred, margined dock needs either a
   different program for the bottom bar (one that can set override-redirect, e.g. polybar,
   or possibly plank / cairo-dock — all three are in the Fedora 44 repos, none installed) or
   giving up the floating look and styling the full-width bar instead. AWAITING A DECISION —
   do not spend more time on xfconf here.
2. xfce4-docklike-plugin and xfce4-statusnotifier-plugin are installed (confirmed present)
   but not yet added to any panel.
3. Fn keys (XF86MonBrightness*, XF86Audio*) not yet verified via `xev` on this keyboard —
   bindings exist in config but firing is unconfirmed.
4. Full logout/login cycle not yet tested — everything so far was hand-started in a
   terminal. Need to confirm the five `exec` lines actually fire on real session start.

## Standing preferences (visual)
Rounded corners + fade animations everywhere. Bottom bar: floating dock look, NOT flush
full-width — visible margin on all sides, like macOS's dock, so corners actually render.
Long-term wishlist, both confirmed technically blocked on this stack and not being chased
further: real macOS-style appmenu (no registrar/consumer packaged on Fedora 44), and
Compiz/KWin-style minimize-to-icon animation (picom animates rectangles only, no
_NET_WM_ICON_GEOMETRY support).

## Liked tools (install if missing, not yet all confirmed installed)
fastfetch, htop, topgrade, cmatrix — general utilities, unrelated to desktop config,
install opportunistically.
