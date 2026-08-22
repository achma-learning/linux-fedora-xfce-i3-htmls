# i3-xfce-fedora

One script to turn a fresh Fedora install into this desktop: **i3 as the window
manager, XFCE's panels and services around it**, with everything already
configured — the two bars, the compositor, rofi, the workspace assignments, the
apps that open at login, and the AI Hub.

```
   git clone <this repo> ~/i3-xfce-fedora
   cd ~/i3-xfce-fedora
   ./install.sh
   # log out, pick the "i3" session
```

Not a distro-hopper's toolkit. It targets **Fedora + X11**, and says so in the
code rather than pretending otherwise.

## What you get

| Workspace | |
|---|---|
| 1 | Thunar |
| 3 | terminal, fullscreen |
| 4 | the AI Hub, and every assistant opened from it — **stacked** |
| 5 | the browser |
| 6 | Obsidian |
| 8 | Anki, fullscreen |
| 10 | cliamp (terminal music player) |

- **Two plain full-width bars**, top and bottom, translucent, XFCE panels — not
  i3bar. Rebuilt exactly, launchers included, from a panel profile archive.
- **picom** with rounded corners, shadows, and animations on open/close,
  workspace switch, focus change and minimise.
- **rofi** as launcher (`$mod+d`, `$mod+space`) and window switcher (`$mod+Tab`).
- **Apps always open where they belong**, whether launched at login or by hand.
- **AI Hub** on workspace 4: a one-screen keyboard launcher for twelve
  assistants, plus a userscript that puts a switcher inside the chatbots. See
  `ai-hub/README.md`.

## The steps

`./install.sh --list` prints them. Each is a standalone POSIX script in `core/`
and can be run, re-run or skipped on its own.

| | | |
|---|---|---|
| 10 | base-packages | XFCE group, i3, picom, rofi, Thunar, panel plugins, X tools |
| 20 | brave | Brave repo, `brave-origin`, set as the default browser |
| 30 | extra-tools | fastfetch, htop, cmatrix, topgrade (COPR) |
| 40 | dotfiles | i3 config, GTK config; validates against the installed i3 |
| 50 | panels | loads the panel profile, restores theme/icons/fonts |
| 60 | obsidian | AppImage + registers its updater with topgrade |
| 70 | anki | official Linux tarball |
| 80 | cliamp | optional — see below |
| 90 | verify | checks what actually landed |

```sh
./install.sh --dry-run     # print every privileged action instead of running it
./install.sh 40 50         # just the configuration, no packages
./core/90-verify.sh        # read-only, safe to run any time
```

Everything overwritten is copied first to
`~/.config/i3-xfce-fedora-backups/<timestamp>/`.

## How it stays honest: `capture.sh`

`install.sh` pushes this repo onto a machine. **`capture.sh` pulls a working
machine back into the repo** — i3 config, picom, rofi, GTK, the panel profile,
xsettings, the scripts, the AI Hub, and an inventory of installed packages.

Change something by hand, run `./capture.sh`, commit. That is what keeps the
repo from quietly drifting away from the machine it claims to describe.

## Layout, and why

```
i3-xfce-fedora/
├── install.sh        run the steps
├── capture.sh        pull this machine back into the repo
├── core/             one script per step + common.sh
├── picom.conf        ← read live, from here
├── rofi/             ←
├── scripts/          ← autostart, minimize, powermenu, browser, aichat…
├── ai-hub/           ←
└── config/           things that get COPIED into ~/.config
    ├── i3/config
    ├── gtk-3.0/
    └── xfce4/        panel profile + xsettings
```

The split is deliberate. Anything the i3 config reads at run time lives at the
repo root and is addressed as `$repo/...`, so **the repo layout is the runtime
layout** — one copy of each file, and editing the clone edits the live setup.
Only what genuinely has to sit in `~/.config` is under `config/`.

The i3 config's single machine-specific line is `set $repo`, stored as
`__REPO__` and filled in at install time. Nothing else needs to know where the
clone lives.

## Two things worth knowing before you change them

**Panel colour comes from xfconf, never from `gtk.css`.** The selector
`.xfce4-panel.background` matches the panel window *and* every out-of-process
plugin's wrapper window. A plug is a real X window whose pixels replace the
panel's, so a `border-radius` there turns each plugin into a pill and
`transparent` punches genuine holes through the bar. Colour the panels with
`background-style` / `background-rgba` per panel and xfce4-panel hands the same
colour to each wrapper itself.

**Browser windows are told apart by instance, not class.** Every window of a
Chromium-family browser has the same `WM_CLASS` class. Only `--app` windows get
an instance derived from their URL. That is the whole reason the AI Hub and the
assistants can live on workspace 4 while ordinary browsing stays on 5.

## What has actually been run

Honesty about testing, because an installer that has never been run is a wish
list:

- **Run and verified** on the reference machine: `capture.sh`, `40-dotfiles`,
  `50-panels` (profile save/load), `60-obsidian`, `90-verify`, and the whole
  installer under `--dry-run`.
- **Not yet run on a fresh machine**: `10-base-packages`, `20-brave`,
  `30-extra-tools`, `70-anki`. They install packages with root, and the
  reference machine already has everything, so they have only been exercised in
  dry-run. Read them before trusting them.
- `80-cliamp` deliberately does nothing unless you give it a URL: cliamp is not
  in the Fedora repos and does not publish a download location in its `--help`,
  so guessing one and shipping it would be worse than asking. Once installed it
  updates itself with `cliamp upgrade`.

## Afterwards

`i3 -C` validates syntax only — it cannot tell whether an app lands on the right
workspace. After logging into the i3 session, check:

- Thunar on 1, terminal on 3 (fullscreen), browser on 5, Anki on 8 (fullscreen),
  Obsidian on 6, cliamp on 10.
- `$mod+Shift+a` opens the AI Hub on 4, and clicking an assistant opens it
  *there*, as its own window, stacked with the hub.
- Neither bar has slivers of wallpaper showing through it.

## Credits

Script structure — POSIX `sh`, a shared `common.sh`, colour constants,
`command_exists`, `$ESCALATION_TOOL` rather than a bare `sudo`, one small
single-purpose script per task — follows
[ChrisTitusTech/linutil](https://github.com/ChrisTitusTech/linutil).
