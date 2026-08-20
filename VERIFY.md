# VERIFY — post-apply checklist

Work through these in order. Each says what "pass" looks like and what to do on failure.

**Before anything:** `i3 -C -c ~/.config/i3/config` must print nothing and exit 0.
It only checks syntax — it cannot tell you a binding points at a missing program, so the
rest of this list is not optional.

## A. Bring the components up by hand (no logout needed)

`exec` lines run only when i3 **starts**. Reloading does not run them, so on the first pass
you start them yourself. Run in a terminal — none of this needs root:

```bash
xfsettingsd &
xfce4-panel &
xfce4-power-manager &
thunar --daemon &
/usr/libexec/xfce-polkit &
```

Then reload i3 to pick up the new config: **`$mod+Shift+c`**.

> **Expected, not a bug:** the moment `xfce4-panel` starts, your tray icons (network,
> bluetooth, updates) migrate from i3bar to the panel's systray. i3bar itself disappears
> only once the new config is live. Seeing both at once means you started the panel but
> have not reloaded yet, or reloaded but not started the panel. Do both and it settles.

From your **next login** onward this section is automatic — that is what the `exec` lines do.

## B. Checklist

1. **Tiling works.** Open two terminals (`$mod+Return` twice). They split the screen, no
   overlap, no titlebars — just a 1px hairline, lighter on the focused one.
2. **Vim focus keys.** `$mod+h/j/k/l` moves focus. `$mod+←↓↑→` does the same.
   *These are not the stock bindings* — the wizard used `j/k/l/semicolon`.
3. **Splits.** `$mod+b` then `$mod+Return` → new terminal appears **beside**. `$mod+v` then
   `$mod+Return` → **below**. (`$mod+h` is focus now, not split.)
4. **Panel visible and reserving space.** The panel is on screen *and* no tiled window slides
   underneath it. Maximise a terminal and confirm it stops at the panel edge.
   → If windows go under it, the panel's `_NET_WM_STRUT_PARTIAL` is not being honoured;
     report it rather than working around it with a gap.
5. **The dock.** Panel-2 (48px, autohiding) still appears when you push the pointer to its
   screen edge, and does not permanently reserve space.
6. **Tray icons.** Network, bluetooth and update icons are in the panel systray and respond
   to clicks. Compare against section A's note before calling this a failure.
7. **rofi launcher.** `$mod+d` opens rofi, typing filters apps, Enter launches.
8. **rofi window switcher.** `$mod+Tab` lists open windows and switches to the one you pick.
9. **Thunar.** `$mod+Shift+Return` opens a file manager window.
10. **Volume keys.** Fn volume up/down/mute change the volume. Verify with `wpctl get-volume
    @DEFAULT_AUDIO_SINK@` before and after. Volume up must stop at `1.00`, not exceed it.
11. **Mic mute key** toggles — `wpctl get-volume @DEFAULT_AUDIO_SOURCE@` shows `[MUTED]`.
12. **Brightness keys.** Fn brightness up/down visibly change the screen. Cross-check
    `cat /sys/class/backlight/intel_backlight/brightness`.
    → If nothing happens, run `brightnessctl set 10%-` in a terminal. If the command works
      but the key does not, the key is not emitting `XF86MonBrightness*` — find out what it
      does emit with `xev` and rebind. If the command itself fails with a permissions error,
      brightnessctl's logind path is not working on this box; report that, do not chmod
      anything under /sys.
13. **Media keys.** With something playing, Play/Pause/Next/Prev work via playerctl.
14. **Screenshot.** `Print` opens xfce4-screenshooter. `$mod+Print` starts a region select.
15. **Compositing.** picom is running (`pgrep picom`). Windows have soft shadows; dragging a
    window or scrolling a video shows no tearing line.
16. **Lock.** `$mod+Escape` locks the screen; your password unlocks it.
17. **Power menu.** `$mod+Shift+e` opens the rofi menu. Press **Escape** — nothing must
    happen. Then pick **Lock** and confirm it locks. Do not test Shut down unless you mean it.
18. **Lid close suspends.** Close the lid, wait, open it. The machine suspends and resumes to
    a locked screen (xss-lock takes the sleep-inhibit lock so the lock is up *before* suspend).
    → If it does not suspend, xfce4-power-manager is not running: `pgrep xfce4-power-manager`.
19. **Polkit.** In Thunar, click a system disk under Devices. A password dialog must appear.
    → No dialog and nothing happens = no polkit agent: `pgrep -f xfce-polkit`. This failure
      is silent by nature, which is exactly why it is on this list.
20. **External display via the dock.** Dock the laptop with a monitor attached, then:
    ```bash
    xrandr --query | grep " connected"
    ```
    The external output (DP-1/DP-2/HDMI-A-1/HDMI-A-2) shows as `connected`. Enable it:
    ```bash
    xrandr --output <EXTERNAL> --auto --right-of eDP-1
    ```
    i3 creates workspaces on the new output; `$mod+1`…`$mod+0` still work.
    → Nothing in the config hardcodes an output name; detect it from the command above.
21. **Restart is safe.** `$mod+Shift+r`. Your layout survives. You do **not** get a second
    panel, a second xfsettingsd, or a second polkit agent — the components use `exec`, which
    does not re-run on restart. Only `picom` (`exec_always`) is re-launched.
22. **Rollback works.** Run `~/i3-setup/undo.sh`, reload with `$mod+Shift+c`, confirm i3bar
    and dmenu return. Then re-apply and reload again. Better to learn this now than at 2am.

23. **Minimize.** Focus a window, press `$mod+m` — it vanishes. Press `$mod+Shift+m` — it
    returns, floating and centred. Press `$mod+Shift+m` again — it hides again.
24. **Minimize animation.** With picom running, `$mod+m` should shrink the window downward
    toward the bottom of the screen while fading; `$mod+Shift+m` reverses it.
    → **This is the one part of the setup I could not verify.** The animation depends on i3's
      scratchpad unmap being seen by picom as its `hide` trigger rather than `close`. The
      config is correct either way — `hide`/`show` are documented, non-experimental triggers,
      and every key is manpage-checked — but whether i3's unmap fires `hide` is a runtime
      question and picom was not running when this was written.
      If the window just disappears with no animation, check with:
      ```bash
      pkill picom; picom --config ~/i3-setup/picom.conf --log-level=debug 2>&1 | grep -i -e anim -e trigger
      ```
      then minimize a window and watch which trigger fires. If it reports `close` instead of
      `hide`, tell me and I will move the animation onto that trigger — a one-line change.

## C. Known limitations, not bugs

- **Binding-mode names are invisible.** The resize mode's name string is drawn by i3bar and
  there is no i3bar. The keys (`h/j/k/l`, `Escape`) are the whole interface.
- **No session save/restore, and no XFCE logout dialog** — `xfce4-session` is not running.
  `$mod+Shift+e` replaces the logout dialog.
- **`i3 -C` passing proves nothing about behaviour.** It checks syntax only. Item 19 in
  particular fails silently and is invisible to validation.
