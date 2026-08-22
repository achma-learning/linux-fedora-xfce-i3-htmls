#!/bin/sh -e
# Put the configuration in place: i3, picom, rofi, GTK.
#
# Everything existing is backed up first, into
# ~/.config/i3-xfce-fedora-backups/<timestamp>/.
. "$(dirname "$0")/common.sh"
checkEnv

CFG="$REPO_ROOT/config"

# --- i3 -----------------------------------------------------------------------
# The config refers to this repo by a variable, `set $repo`, which the stored
# copy leaves as __REPO__. That is the ONLY machine-specific line in it: every
# script, theme and helper it calls is addressed through that one variable, so
# the repo can be cloned anywhere.
msg "installing the i3 config"
backup "$HOME/.config/i3/config"
run mkdir -p "$HOME/.config/i3"
if [ "${DRY_RUN:-0}" = "1" ]; then
    printf "%b\n" "${YELLOW}would write:${RC} ~/.config/i3/config with \$repo = $REPO_ROOT"
else
    sed "s|^set \$repo .*|set \$repo $REPO_ROOT|" "$CFG/i3/config" > "$HOME/.config/i3/config"
    grep -q "^set \$repo $REPO_ROOT$" "$HOME/.config/i3/config" \
        || die "the \$repo line was not substituted — check config/i3/config"
fi

# Validate against the INSTALLED i3 binary before anything depends on it.
# This checks syntax only: it cannot tell whether an exec target exists or
# whether a for_window rule will ever match. 90-verify.sh covers what it misses.
if command_exists i3 && [ "${DRY_RUN:-0}" != "1" ]; then
    i3 -C -c "$HOME/.config/i3/config" >/dev/null || die "the installed i3 rejects this config"
    ok "i3 config installed and validated"
fi

# --- picom, rofi --------------------------------------------------------------
# Nothing to install. picom.conf, rofi/, scripts/ and ai-hub/ live at the root
# of this repo and the i3 config reads them from there ($repo/picom.conf,
# $repo/rofi/...), so the repo layout IS the runtime layout — one copy of each
# file, and editing it in the clone is editing the live config.
msg "checking the files the i3 config reads from this repo"
missing=0
for f in "$REPO_ROOT/picom.conf" "$REPO_ROOT/rofi/macos-adjacent.rasi" \
         "$REPO_ROOT/scripts/autostart.sh" "$REPO_ROOT/ai-hub/bin/ai-hub"; do
    [ -r "$f" ] || { warn "missing: $f"; missing=$((missing + 1)); }
done
[ "$missing" -eq 0 ] && ok "all in place" || die "$missing file(s) missing — is this a complete clone?"

# --- GTK ----------------------------------------------------------------------
# gtk.css @imports colors.css, which needs the assets, so the whole directory
# ships together. Colouring the panels is NOT done here — see 50-panels.sh and
# the long comment at the top of gtk.css for why that has to be xfconf.
msg "installing GTK config"
backup "$HOME/.config/gtk-3.0"
run mkdir -p "$HOME/.config/gtk-3.0"
run cp -a "$CFG/gtk-3.0/." "$HOME/.config/gtk-3.0/"
ok "gtk-3.0 installed"

# --- executables --------------------------------------------------------------
run chmod +x "$REPO_ROOT"/scripts/*.sh "$REPO_ROOT"/ai-hub/bin/* 2>/dev/null || true
ok "scripts made executable"
