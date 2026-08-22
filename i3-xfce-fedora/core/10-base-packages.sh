#!/bin/sh -e
# The desktop itself: XFCE's pieces, i3, and the X tools this setup leans on.
. "$(dirname "$0")/common.sh"
checkEnv

# Package names verified against a working install with `rpm -q` — note Thunar
# is capitalised in Fedora, and there is no xfce4-statusnotifier-plugin.
XFCE="xfce4-panel xfce4-settings xfce4-power-manager xfce4-appfinder \
xfce4-terminal xfce4-screenshooter xfce4-notifyd xfce-polkit garcon tumbler \
Thunar thunar-volman thunar-archive-plugin \
xfce4-whiskermenu-plugin xfce4-docklike-plugin xfce4-pulseaudio-plugin \
xfce4-clipman-plugin xfce4-panel-profiles"

# i3 and the compositing/launcher layer that makes it look like this.
I3="i3 picom rofi kitty"

# Tray applets the panel expects to find, and the tools the scripts call.
TOOLS="network-manager-applet blueman pavucontrol \
xprop ImageMagick jq curl python3 flatpak"

# libfuse.so.2. Without it an AppImage cannot mount itself and exits with
# "AppImages require FUSE to run" — which is why 60-obsidian.sh unpacks instead.
# Installing it here means the AppImage also works directly.
FUSE="fuse-libs"

msg "installing the XFCE desktop group"
run "$ESCALATION_TOOL" dnf install -y @xfce-desktop-environment

msg "installing i3, XFCE components and tools"
# shellcheck disable=SC2086
run "$ESCALATION_TOOL" dnf install -y $XFCE $I3 $TOOLS $FUSE

ok "base packages installed"
printf "%b\n" "${YELLOW}note:${RC} log out and pick the ${BOLD}i3${RC} session at the login screen."
printf "%b\n" "      The XFCE session entry stays installed on purpose — it is the way back"
printf "%b\n" "      if something here goes wrong."
