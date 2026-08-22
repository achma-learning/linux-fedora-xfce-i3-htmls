#!/bin/sh -e
# The everyday extras. Nothing here is required for the desktop to work.
. "$(dirname "$0")/common.sh"
checkEnv

msg "installing extras"
run "$ESCALATION_TOOL" dnf install -y fastfetch htop cmatrix

# topgrade lives in a COPR, not in Fedora proper. It is worth having because
# 60-obsidian.sh registers itself with it, so "update everything" covers the
# AppImage too.
if ! command_exists topgrade; then
    msg "enabling the topgrade COPR"
    run "$ESCALATION_TOOL" dnf copr enable -y lilay/topgrade
    run "$ESCALATION_TOOL" dnf install -y topgrade
else
    ok "topgrade already installed"
fi

ok "extras installed"
