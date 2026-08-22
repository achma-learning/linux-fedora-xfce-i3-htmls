#!/usr/bin/env bash
# autostart.sh -- the apps that should already be open when the session starts.
#
# ONE line per app. This is the file to edit when the daily set changes; the i3
# config just calls this once, with `exec` (not exec_always), so it runs at
# login and not again on every i3 restart.
#
# WHERE each app lands is NOT decided here -- it is decided by the `assign`
# rules in ~/.config/i3/config, which key off WM_CLASS / instance / role. That
# split is deliberate: opening an app by hand later puts it in the same place
# as opening it at login.
#
#   thunar                     -> workspace 1
#   xfce4-terminal             -> workspace 3, fullscreen (--role=main-term)
#   brave-origin (default browser) -> workspace 5
#   anki                       -> workspace 8, fullscreen
#   cliamp in a terminal       -> workspace 10   (via --role=cliamp)
#
# The stagger is not superstition: five apps racing for CPU and disk at login
# makes all five slow, and Anki and the browser are the two heavy ones. Nothing
# here depends on the order, so if you add an app just append a line.

set -u

launch() { command -v "$1" >/dev/null || { echo "autostart: $1 not installed, skipped" >&2; return; }; "$@" & }

# The browser is resolved at run time rather than hardcoded, the same way
# scripts/aichat.sh does it, so this keeps working if the default changes.
default_browser() {
  local desktop d exec_line
  desktop=$(xdg-settings get default-web-browser 2>/dev/null) || return 1
  for d in "${XDG_DATA_HOME:-$HOME/.local/share}/applications" \
           /usr/local/share/applications /usr/share/applications; do
    if [ -r "$d/$desktop" ]; then
      exec_line=$(grep -m1 '^Exec=' "$d/$desktop" | cut -d= -f2-)
      # shellcheck disable=SC2001
      echo "${exec_line//%[UuFfic]/}"
      return 0
    fi
  done
  return 1
}

launch thunar
sleep 1

# --role=main-term does two jobs: it marks this as THE session terminal (i3
# opens it fullscreen on workspace 3) without making every terminal you open
# later fullscreen too.
launch xfce4-terminal --role=main-term
sleep 1

# cliamp is a terminal program, so it needs a terminal. --role is what makes
# this window distinguishable from the plain terminal above: xfce4-terminal
# gives every window the same WM_CLASS, but it passes --role through, and i3's
# `assign` can match on window_role. Verified with xprop.
launch xfce4-terminal --role=cliamp --title=cliamp --command=cliamp
sleep 2

if browser=$(default_browser); then
  # shellcheck disable=SC2086
  $browser &
else
  echo "autostart: no default browser found, skipped" >&2
fi
sleep 2

launch anki

wait
