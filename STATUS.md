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
- All committed to git in this repo; ROLLBACK.md / undo.sh tested and working

## Still open, in priority order
1. Bottom panel (panel-2) is full-width and flush to the screen edge, so picom's rounded
   corners are clipped off-screen and invisible. Needs: shrink to content-width or a fixed
   %, centered, PLUS vertical margin from the bottom edge. xfce4-panel version + available
   xfconf properties not yet checked.
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
