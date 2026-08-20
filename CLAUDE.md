# Non-negotiable constraints for this project

- NEVER run `sudo`. Print root commands in a fenced block and stop; the user runs them.
- NEVER modify /etc, /usr, or display-manager configuration.
- NEVER remove or disable the XFCE session entry — it is the rollback path.
- NEVER restart X, log the user out, or run `i3-msg restart`.
- Back up every file to backups/<timestamp>/ before first modification.
- Validate with `i3 -C -c <file>` before moving any config into place.
- No hardcoded /home/<user>/ paths, no hardcoded audio sink indices, no hardcoded outputs.
- Config syntax authority (there is NO `man 5 i3` on this machine): `i3 -C -c <file>`
  against the installed binary > docs/userguide.txt > i3wm.org > GitHub RELEASE-NOTES-*.
  `man 1 i3` covers CLI flags only. Never answer a syntax question from memory.
- `i3 -C` validates SYNTAX ONLY. It does not verify that exec targets exist on $PATH, that
  for_window/assign criteria ever match a real window, or that a directive does anything
  non-trivial in this version — a config can pass validation and still be silently inert.
- Do not configure i3bar / i3status / i3blocks. xfce4-panel is the bar.
- ROUTE B is the plan: the user logs into the standalone i3 session (`i3.desktop`), NOT XFCE.
  XFCE components (xfsettingsd, xfce4-panel, xfce4-power-manager, thunar --daemon) run as
  i3 clients via `exec --no-startup-id` in ~/.config/i3/config. NEVER change xfconf
  Client0_Command and never clear the session cache — those were Route A and are out of scope.
  Both existing panels stay (panel-1 top bar, panel-2 autohiding dock).
- ~/.config/i3/config is NOT greenfield — it is the live wizard config of the running
  session. Edit in place and show a diff of every change.
- Never pipe stderr into a filter (`cmd 2>&1 | grep x`): a missing binary then reads as an
  empty result rather than an error. Verify negatives with `command -v` or an exit status.
- Work only inside ~/i3-setup and ~/.config/i3. Never read or write elsewhere in $HOME
  without asking first.
