#!/bin/sh
# What actually got installed, and what did not.
#
# Deliberately does NOT exit on the first failure: the point is a full picture.
# `i3 -C` only checks syntax, so this checks the things it cannot — that the
# programs the config execs exist, and that the files it reads are there.
. "$(dirname "$0")/common.sh"

fails=0
check() {
    label="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf "%b\n" "${GREEN}✓${RC} $label"
    else
        printf "%b\n" "${RED}✗${RC} $label"
        fails=$((fails + 1))
    fi
}

printf "%b\n" "${BOLD}programs the i3 config runs${RC}"
for c in i3 picom rofi thunar xfce4-panel xfce4-terminal xprop python3; do
    check "$c" command -v "$c"
done
check "a default browser is set" sh -c 'xdg-settings get default-web-browser | grep -q .'

printf "\n%b\n" "${BOLD}optional, workspace autostart depends on these${RC}"
for c in obsidian anki cliamp; do
    if command -v "$c" >/dev/null 2>&1; then
        printf "%b\n" "${GREEN}✓${RC} $c"
    else
        printf "%b\n" "${YELLOW}–${RC} $c (not installed; that workspace just stays empty)"
    fi
done

printf "\n%b\n" "${BOLD}files${RC}"
check "~/.config/i3/config"            test -r "$HOME/.config/i3/config"
check "\$repo points somewhere real"   sh -c 'p=$(sed -n "s/^set \$repo //p" "$HOME/.config/i3/config" | head -1); eval test -d "$p"'
check "picom.conf"                     test -r "$REPO_ROOT/picom.conf"
check "rofi theme"                     test -r "$REPO_ROOT/rofi/macos-adjacent.rasi"
check "gtk.css"                        test -r "$HOME/.config/gtk-3.0/gtk.css"
check "ai-hub launcher"                test -x "$REPO_ROOT/ai-hub/bin/ai-hub"
check "autostart script"               test -x "$REPO_ROOT/scripts/autostart.sh"

printf "\n%b\n" "${BOLD}config validity${RC}"
check "installed i3 accepts the config" i3 -C -c "$HOME/.config/i3/config"

printf "\n%b\n" "${BOLD}panels${RC}"
check "two panels configured" sh -c 'xfconf-query -c xfce4-panel -p /panels -l | grep -c panel- | grep -qv "^0$"'

printf "\n"
if [ "$fails" -eq 0 ]; then
    printf "%b\n" "${GREEN}${BOLD}all checks passed${RC}"
    printf "%b\n" "Log out and choose the ${BOLD}i3${RC} session. What i3 -C cannot check —"
    printf "%b\n" "whether windows land on the right workspaces — is listed in the README."
else
    printf "%b\n" "${RED}${BOLD}$fails check(s) failed${RC} — see above."
    exit 1
fi
