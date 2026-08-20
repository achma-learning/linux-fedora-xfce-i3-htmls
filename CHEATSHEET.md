# i3 cheatsheet — `$mod` is the **Super** key (Mod4)

Generated from `config.staged`. Every binding below is in that file.

## Launching
| Keys | Action |
|---|---|
| `$mod+Return` | xfce4-terminal |
| `$mod+Shift+Return` | Thunar |
| `$mod+space` | rofi — application launcher (Spotlight) |
| `$mod+d` | rofi — application launcher (same thing, older habit) |
| `$mod+Tab` | rofi — window switcher |
| `Print` | Screenshot (xfce4-screenshooter) |
| `$mod+Print` | Screenshot, region select |

## Focus and movement
| Keys | Action |
|---|---|
| `$mod+h / j / k / l` | Focus left / down / up / right |
| `$mod+←↓↑→` | Same, arrow keys (identical bindings) |
| `$mod+Shift+h/j/k/l` | Move window left / down / up / right |
| `$mod+Shift+←↓↑→` | Same, arrow keys |
| `$mod+a` | Focus parent container (select a whole split) |
| `$mod+t` | Jump between the tiling and floating layers |

> Note: this is **not** the i3 default. The stock wizard config uses `j/k/l/semicolon`
> (shifted one key right). These are true vim directions.

> `$mod+space` used to be `focus mode_toggle` in the stock config. It is the launcher now;
> the tiling/floating toggle moved to `$mod+t`.

## Layout
| Keys | Action |
|---|---|
| `$mod+b` | Next window splits **horizontally** (side by side) |
| `$mod+v` | Next window splits **vertically** (stacked) |
| `$mod+s` | Stacking layout (titles in a vertical list) |
| `$mod+w` | Tabbed layout (titles in a row) |
| `$mod+e` | Toggle split direction |
| `$mod+f` | Fullscreen toggle |
| `$mod+Shift+space` | Float / unfloat this window |
| `$mod+m` | **Minimize** — send window to the scratchpad |
| `$mod+Shift+m` | **Un-minimize** — recall a scratchpad window |
| — | Gaps are 8px inner, and vanish when a workspace holds one window (`smart_gaps on`) |
| `$mod+Shift+q` | Close window |
| `$mod+r` | Enter **resize mode** |

> `$mod+b` is horizontal split because `$mod+h` is focus-left here. In the stock
> config `$mod+h` was the split — that binding is gone.

### Resize mode (`$mod+r`)
`h/j/k/l` or arrows resize by 10px. Hold `Shift` for 1px. `Enter`, `Escape`, or `$mod+r` exits.

> The mode's name string is **not shown on screen** — i3bar draws that, and this setup has
> no i3bar. The keys are the vim directions; nothing else to remember.

## Workspaces
| Keys | Action |
|---|---|
| `$mod+1` … `$mod+0` | Switch to workspace 1–10 |
| `$mod+Shift+1` … `$mod+Shift+0` | Move window to workspace 1–10 |

## Session
| Keys | Action |
|---|---|
| `$mod+Escape` | Lock now |
| `$mod+Shift+e` | **Power menu** (rofi): Lock / Log out / Reboot / Shut down |
| `$mod+Shift+c` | Reload config (applies bindings, colours, rules) |
| `$mod+Shift+r` | Restart i3 in place (keeps your layout) |

> Destructive power-menu entries ask a second time. Escape at either prompt does nothing.
> Reload does **not** re-run the `exec` lines — see ROLLBACK.md.

## Laptop keys
| Key | Action |
|---|---|
| Volume up / down / mute | `wpctl` on `@DEFAULT_AUDIO_SINK@` (resolved at press time) |
| Mic mute | `wpctl` on `@DEFAULT_AUDIO_SOURCE@` |
| Brightness up / down | `brightnessctl set 5%±` (via logind) |
| Play / Next / Prev | `playerctl` (MPRIS) |

Volume up is capped at 100% (`-l 1.0`) so repeated presses can't boost past unity.

## Adding a floating rule for an app
Window criteria are the one thing `i3 -C` cannot check — a rule can be syntactically
perfect and match nothing, forever, silently. Always read the real values off a real window:

```bash
xprop | grep -E 'WM_CLASS|WM_WINDOW_ROLE'   # then click the window
```

Output looks like `WM_CLASS(STRING) = "anki", "Anki"`. The **first** string is `instance`,
the **second** is `class`. Add to `~/.config/i3/config`:

```
for_window [class="Anki"] floating enable
```

then `$mod+Shift+c` to reload, and open the window again to confirm.

**Anki specifically:** its main window deliberately tiles. Its dialogs float already via the
generic `window_type="dialog"` rule. If the **Browse** window tiles badly, run the `xprop`
recipe on it — it may report a normal window type — and add a rule using its `title` or
`class`. That is a one-line change.


## Visual baseline — KEEP THESE

These are settled. **Any future change that would remove one of them must be flagged to me
before it is made**, not applied and mentioned afterwards:

1. **Rounded corners** — `corner-radius = 10` in `picom.conf`, with square corners only where
   they are deliberate (the top panel, fullscreen windows, i3 helper windows).
2. **Full-width bottom dock** — panel-2, the 48px autohiding launcher bar. Both panels stay;
   the dock is rounded and shadowed, the top panel is flush.
3. **Fade animations** — `fading = true` plus the `animations` block. Windows fade and scale
   on open/close, and shrink downward on minimize.

Things that would quietly break one of these: switching picom's `rules` back to the legacy
exclude options, setting `corner-radius = 0` globally, removing panel-2 from
`/panels/plugin-ids`, or setting `fading = false`.

## Global application menu (macOS menu bar) — NOT possible on Fedora 44

Decided against, because the pieces do not exist in the repos. Verified with
`dnf search appmenu` and `dnf search vala-panel` on 2026-08-20:

- `appmenu-qt5` and `appmenu-qt5-profile.d` exist — these are **exporters only**.
- `vala-panel` — **"No matches found"**. No `vala-panel-appmenu`, so no *registrar*
  and no *panel consumer*.
- No `appmenu-gtk3-module`, so GTK apps could not export a menu either.

A global menubar needs three parts: an exporter (per toolkit), a registrar (D-Bus
service collecting menus), and a panel plugin to display them. Fedora 44 ships only the
first, for Qt. Getting the rest means building `vala-panel-appmenu` from source.

> **Do not install `appmenu-qt5` or `appmenu-qt5-profile.d`.**
> They make Qt applications *export* their menubar over D-Bus and **remove it from the
> application window**. With no registrar and no panel plugin to display it, the menu
> would be exported into nothing — **Anki and every other Qt app would lose its menu bar
> entirely, with nowhere for it to appear.** The profile.d package makes this system-wide
> for every Qt5 app at login, which is worse.


## Minimize — how it actually works

i3 has **no minimize**. The nearest thing is the **scratchpad**, and it behaves differently
enough to be worth reading once (userguide 6.21, "Scratchpad").

| Keys | What happens |
|---|---|
| `$mod+m` | Sends the focused window to the scratchpad. It vanishes. |
| `$mod+Shift+m` | Brings a scratchpad window back, **floating and centred** on the current workspace. |

**Read this part.** The userguide says of the scratchpad workspace: *"There is no way to open
that workspace."* A window you send there is **invisible and unreachable except through
`$mod+Shift+m`**. It will not appear in the panel's window list, it is not on any workspace
you can switch to, and `$mod+Tab` (rofi window switcher) will not show it. If you forget the
recall binding, the window is effectively gone until you remember it — that is the one real
sharp edge here.

Other things worth knowing:

- Pressing `$mod+Shift+m` again while a scratchpad window is **visible** hides it again, so it
  works as a toggle once the window is up.
- With **several** windows in the scratchpad, repeated `$mod+Shift+m` **cycles** through them.
- A recalled window comes back **floating**, not tiled — even if it was tiled when you
  minimized it. To put it back in the tiling layout, press `$mod+Shift+space`.
- To pull a *specific* window back rather than cycling, use criteria:
  `bindsym $mod+n [class="Anki"] scratchpad show`

The downward shrink-and-fade is picom's `hide` animation, not i3's — i3 only unmaps the
window. If the animation does not play, the config is still correct; see VERIFY.md.
