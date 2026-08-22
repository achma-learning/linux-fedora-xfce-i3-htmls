#!/bin/sh
# Shared helpers for every task script.
#
# Structure and conventions are modelled on ChrisTitusTech/linutil: POSIX sh,
# colour constants, command_exists, an $ESCALATION_TOOL rather than a bare
# `sudo`, and one small single-purpose script per task so any of them can be
# run, re-run or skipped on its own.
#
# Difference from linutil worth stating: this repo targets ONE system — Fedora
# with X11 — so there is no $PACKAGER abstraction. Pretending to be
# distro-agnostic while only ever being tested on Fedora would be a lie in the
# code.

# shellcheck disable=SC2034
RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
GREEN='\033[32m'
BOLD='\033[1m'

command_exists() {
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || return 1
    done
    return 0
}

msg()  { printf "%b\n" "${CYAN}$*${RC}"; }
ok()   { printf "%b\n" "${GREEN}✓ $*${RC}"; }
warn() { printf "%b\n" "${YELLOW}! $*${RC}" >&2; }
die()  { printf "%b\n" "${RED}✗ $*${RC}" >&2; exit 1; }

# DRY_RUN=1 turns every privileged or destructive action into a printed line.
run() {
    if [ "${DRY_RUN:-0}" = "1" ]; then
        printf "%b\n" "${YELLOW}would run:${RC} $*"
        return 0
    fi
    "$@"
}

checkEnv() {
    [ "$(id -u)" -ne 0 ] || die "run this as your normal user, not root — it writes into \$HOME"

    command_exists dnf || die "this is a Fedora setup; dnf was not found"

    if command_exists sudo; then
        ESCALATION_TOOL=sudo
    elif command_exists doas; then
        ESCALATION_TOOL=doas
    else
        die "neither sudo nor doas found"
    fi
    export ESCALATION_TOOL

    # X11 only. i3 is an X window manager, picom is an X compositor, and the
    # panel tricks here depend on X window properties.
    if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
        warn "this is a Wayland session; the result only works under X11 (log into the i3 session)"
    fi
}

# Back up a file or directory before overwriting it. Every task uses this, so
# nothing is ever destroyed without a copy next to it.
backup() {
    target="$1"
    [ -e "$target" ] || return 0
    stamp="${BACKUP_DIR:-$HOME/.config/i3-xfce-fedora-backups}/$(date +%Y%m%d-%H%M%S)"
    run mkdir -p "$stamp"
    run cp -a "$target" "$stamp/" && msg "backed up $target -> $stamp/"
}

# Repo root, regardless of where the caller ran from.
REPO_ROOT=${REPO_ROOT:-$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)}
export REPO_ROOT
