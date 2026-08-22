#!/bin/sh -e
# cliamp — the terminal music player that autostart.sh opens on workspace 10.
#
# THIS IS THE ONE THING THE INSTALLER CANNOT FETCH FOR YOU. cliamp is not in
# the Fedora repos and its own `--help` does not name a download location, so
# rather than guess at a URL and bake a wrong one into an installer, this step
# asks for it.
#
# Once installed it maintains itself: `cliamp upgrade` pulls its own updates.
#
# Set CLIAMP_URL to the release binary and this becomes automatic:
#   CLIAMP_URL=https://…/cliamp_linux_amd64 ./core/80-cliamp.sh
. "$(dirname "$0")/common.sh"
checkEnv

DEST="$HOME/.local/bin/cliamp"

if command_exists cliamp; then
    ok "cliamp already installed: $(cliamp --version 2>/dev/null | head -1)"
    exit 0
fi

if [ -z "${CLIAMP_URL:-}" ]; then
    warn "cliamp not installed and CLIAMP_URL is not set — skipping."
    printf "%b\n" "      Install it yourself into ~/.local/bin/cliamp, or re-run this step with"
    printf "%b\n" "      CLIAMP_URL pointing at the release binary."
    printf "%b\n" "      Everything else works without it; workspace 10 just stays empty."
    exit 0
fi

msg "downloading cliamp"
run mkdir -p "$(dirname "$DEST")"
run curl -fL --progress-bar -o "$DEST" "$CLIAMP_URL"
run chmod +x "$DEST"
ok "cliamp installed at $DEST"
