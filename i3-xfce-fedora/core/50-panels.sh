#!/bin/sh -e
# Rebuild both xfce4-panels exactly as they are on the reference machine, and
# restore the GTK/icon theme settings.
#
# Why a profile archive rather than a list of xfconf-query calls: the panels
# carry launchers, and each launcher is a generated .desktop file with its own
# id. xfce4-panel-profiles serialises all of it — both panels, every plugin,
# every launcher — into one archive, and loads it back the same way.
. "$(dirname "$0")/common.sh"
checkEnv

PROFILE="$REPO_ROOT/config/xfce4/panel-profile.tar.bz2"

command_exists xfce4-panel-profiles || die "xfce4-panel-profiles is not installed (run 10-base-packages.sh)"
[ -r "$PROFILE" ] || die "no panel profile at $PROFILE"

# xfce4-panel-profiles replaces the whole panel configuration, so keep a copy
# of what is there now — including the case where it is Fedora's stock panel.
msg "saving the current panel layout before replacing it"
BK="${BACKUP_DIR:-$HOME/.config/i3-xfce-fedora-backups}/$(date +%Y%m%d-%H%M%S)"
run mkdir -p "$BK"
run xfce4-panel-profiles save "$BK/panel-before.tar.bz2" || warn "could not save the existing layout"

msg "loading the panel profile"
run xfce4-panel-profiles load "$PROFILE"

# The panel has to be restarted to pick up plugin changes. Settings that only
# change colour or size apply live, but the plugin list does not.
if command_exists xfce4-panel; then
    msg "restarting xfce4-panel"
    run xfce4-panel -r >/dev/null 2>&1 || true
fi

# --- xsettings ----------------------------------------------------------------
# GTK theme, icon theme, fonts, DPI, antialiasing. Without these the panels are
# the right shape but the wrong colour and the wrong icons.
if [ -r "$REPO_ROOT/config/xfce4/xsettings.sh" ]; then
    msg "restoring xsettings (theme, icons, fonts)"
    if [ "${DRY_RUN:-0}" = "1" ]; then
        printf "%b\n" "${YELLOW}would replay:${RC} $(grep -c xfconf-query "$REPO_ROOT/config/xfce4/xsettings.sh") xfconf properties"
    else
        # Each line is a self-contained xfconf-query call; a property that no
        # longer exists in this XFCE version should not abort the rest.
        while IFS= read -r line; do
            case "$line" in \#*|'') continue ;; esac
            eval "$line" 2>/dev/null || warn "skipped: $line"
        done < "$REPO_ROOT/config/xfce4/xsettings.sh"
    fi
    ok "xsettings restored"
fi

ok "panels rebuilt"
printf "%b\n" "${YELLOW}note:${RC} the panels are plain full-width bars by design. Their colour comes"
printf "%b\n" "      from per-panel xfconf (background-style/background-rgba), NOT from gtk.css —"
printf "%b\n" "      that selector also matches every plugin's wrapper window and punches holes."
