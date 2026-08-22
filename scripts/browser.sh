#!/usr/bin/env bash
# browser.sh -- open the default web browser, resolved at run time.
#
# Bound to $mod+b. Not hardcoded to Brave: `xdg-settings get
# default-web-browser` names a .desktop file, and its Exec= line is what
# actually gets run, so changing the default browser changes this binding with
# no config edit. An ordinary window, not --app mode — that is what
# ai-hub/bin/ai-open is for.
set -euo pipefail

desktop=$(xdg-settings get default-web-browser 2>/dev/null || true)
exec_line=""
if [ -n "$desktop" ]; then
  for d in "${XDG_DATA_HOME:-$HOME/.local/share}/applications" \
           /usr/local/share/applications /usr/share/applications; do
    [ -r "$d/$desktop" ] || continue
    exec_line=$(grep -m1 '^Exec=' "$d/$desktop" | cut -d= -f2-)
    break
  done
fi
[ -n "$exec_line" ] || exec_line=$(command -v xdg-open || true)
[ -n "$exec_line" ] || { echo "browser.sh: no default browser found" >&2; exit 1; }

# shellcheck disable=SC2206
cmd=( ${exec_line//%[UuFfic]/} )
exec "${cmd[@]}"
