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
- Work only inside ~/i3-setup and ~/.config/i3. Never read or write elsewhere in $HOME
  without asking first.
