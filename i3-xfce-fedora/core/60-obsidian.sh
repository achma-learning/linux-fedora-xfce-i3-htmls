#!/bin/sh -e
# Obsidian, from its AppImage, plus registering the updater with topgrade.
. "$(dirname "$0")/common.sh"
checkEnv

UPDATER="$REPO_ROOT/scripts/obsidian-update.sh"
[ -x "$UPDATER" ] || die "missing $UPDATER"

msg "installing Obsidian"
run "$UPDATER"

# topgrade knows nothing about AppImages, so tell it. The updater is a no-op
# when Obsidian is already current, so running it on every topgrade is cheap.
TG="$HOME/.config/topgrade.toml"
if [ "${DRY_RUN:-0}" = "1" ]; then
    printf "%b\n" "${YELLOW}would register:${RC} the Obsidian updater in $TG"
elif [ -f "$TG" ] && grep -q 'obsidian-update' "$TG"; then
    ok "already registered with topgrade"
else
    msg "registering the updater with topgrade"
    [ -f "$TG" ] || printf '[commands]\n' > "$TG"
    grep -q '^\[commands\]' "$TG" || printf '\n[commands]\n' >> "$TG"
    # Append under [commands]. Written with the repo path resolved, because
    # topgrade runs the value through a shell but not through this repo's idea
    # of where it lives.
    printf '\n# Obsidian is an AppImage, so no package manager tracks it.\n"Obsidian" = "%s"\n' \
        "$UPDATER" >> "$TG"
    ok "registered"
fi

ok "Obsidian ready (run it with: obsidian)"
