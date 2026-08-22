#!/bin/sh -e
# Anki, from the official Linux tarball.
#
# Anki is not in the Fedora repos and its Flatpak lags, so this uses the
# upstream tarball, which ships its own install.sh and puts things under
# /usr/local. That is the only reason this step needs root.
#
# UNTESTED on a fresh machine — see README, "What has actually been run".
. "$(dirname "$0")/common.sh"
checkEnv

if command_exists anki && [ "${FORCE:-0}" != "1" ]; then
    ok "anki already installed at $(command -v anki)"
    exit 0
fi

for c in curl jq tar; do command_exists "$c" || die "needs $c"; done

msg "asking GitHub for the latest Anki release"
rel=$(curl -fsSL "https://api.github.com/repos/ankitects/anki/releases/latest") \
    || die "could not reach the GitHub API"

tag=$(printf '%s' "$rel" | jq -r '.tag_name')
# Qt6 build for x86_64. The .zst tarball is the normal desktop download.
url=$(printf '%s' "$rel" | jq -r '.assets[] | select(.name | test("linux-qt6\\.tar\\.zst$")) | .browser_download_url' | head -1)
[ -n "$url" ] || die "no linux-qt6 tarball in release $tag"

msg "installing Anki $tag"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
run curl -fL --progress-bar -o "$tmp/anki.tar.zst" "$url"
run tar --use-compress-program=unzstd -xf "$tmp/anki.tar.zst" -C "$tmp"

dir=$(find "$tmp" -maxdepth 1 -type d -name 'anki-*' | head -1)
[ -n "$dir" ] || die "unexpected tarball layout"
run "$ESCALATION_TOOL" sh -c "cd '$dir' && ./install.sh"

ok "Anki installed"
