#!/bin/sh -e
# Brave Origin, and making it the default browser.
#
# It matters that it is the DEFAULT rather than hardcoded anywhere: the AI Hub,
# the $mod+b binding and scripts/aichat.sh all resolve the browser through
# `xdg-settings get default-web-browser` at run time, so swapping browsers later
# needs no config edits.
. "$(dirname "$0")/common.sh"
checkEnv

REPO_FILE=/etc/yum.repos.d/brave-browser.repo

if [ ! -f "$REPO_FILE" ]; then
    msg "adding the Brave repository"
    run "$ESCALATION_TOOL" dnf config-manager addrepo \
        --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
else
    ok "Brave repository already present"
fi

msg "installing brave-origin"
run "$ESCALATION_TOOL" dnf install -y brave-origin

# The desktop file name is what xdg-settings wants, not the binary name.
for d in /usr/share/applications /usr/local/share/applications; do
    if [ -r "$d/brave-origin.desktop" ]; then
        msg "setting brave-origin as the default browser"
        run xdg-settings set default-web-browser brave-origin.desktop
        break
    fi
done

ok "browser ready: $(command -v brave-origin-stable 2>/dev/null || echo 'brave-origin-stable not on PATH yet')"
