#!/usr/bin/env bash
# install.sh -- turn a fresh Fedora machine into this i3 + XFCE setup.
#
# Runs the numbered scripts in core/ in order. Each one is independent and
# re-runnable, so a failed or skipped step can be run again on its own:
#
#   ./install.sh                 everything, in order
#   ./install.sh --list          what the steps are
#   ./install.sh --dry-run       print privileged actions instead of doing them
#   ./install.sh 40 50           only those steps
#   ./core/50-panels.sh          or call one directly
#
# Structure follows ChrisTitusTech/linutil: one small POSIX script per task, a
# shared core/common.sh, and $ESCALATION_TOOL instead of a hardcoded sudo.

set -uo pipefail
REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
export REPO_ROOT
. "$REPO_ROOT/core/common.sh"

steps() { find "$REPO_ROOT/core" -maxdepth 1 -name '[0-9][0-9]-*.sh' | sort; }

usage() {
    printf "%b\n" "${BOLD}i3-xfce-fedora${RC}"
    printf "%s\n" "usage: ./install.sh [--list] [--dry-run] [--yes] [NN ...]"
    printf "\n%b\n" "${BOLD}steps${RC}"
    for s in $(steps); do
        n=$(basename "$s"); num=${n%%-*}
        desc=$(sed -n '2s/^# //p' "$s")
        printf "  %s  %-22s %s\n" "$num" "${n#*-}" "$desc"
    done
}

ASSUME_YES=0
WANTED=()
for arg in "$@"; do
    case "$arg" in
        --list|-l) usage; exit 0 ;;
        --dry-run) export DRY_RUN=1 ;;
        --yes|-y)  ASSUME_YES=1 ;;
        --help|-h) usage; exit 0 ;;
        [0-9][0-9]) WANTED+=("$arg") ;;
        *) die "unknown argument: $arg (try --list)" ;;
    esac
done

checkEnv

selected=()
for s in $(steps); do
    num=$(basename "$s"); num=${num%%-*}
    if [ ${#WANTED[@]} -eq 0 ]; then
        selected+=("$s")
    else
        for w in "${WANTED[@]}"; do [ "$w" = "$num" ] && selected+=("$s"); done
    fi
done
[ ${#selected[@]} -gt 0 ] || die "nothing selected (try --list)"

printf "%b\n" "${BOLD}About to run:${RC}"
for s in "${selected[@]}"; do printf "  %s\n" "$(basename "$s")"; done
[ "${DRY_RUN:-0}" = "1" ] && printf "%b\n" "${YELLOW}(dry run — nothing will be changed)${RC}"
printf "\n%b\n" "This installs packages with $ESCALATION_TOOL and replaces your i3, picom,"
printf "%s\n" "rofi and GTK configuration. Everything it overwrites is backed up first to"
printf "%s\n\n" "~/.config/i3-xfce-fedora-backups/."

if [ "$ASSUME_YES" != "1" ] && [ "${DRY_RUN:-0}" != "1" ]; then
    printf "Continue? [y/N] "
    read -r reply
    case "$reply" in [Yy]*) ;; *) msg "aborted"; exit 0 ;; esac
fi

failed=()
for s in "${selected[@]}"; do
    printf "\n%b\n" "${BOLD}── $(basename "$s") ──${RC}"
    if "$s"; then :; else
        warn "$(basename "$s") failed"
        failed+=("$(basename "$s")")
    fi
done

printf "\n"
if [ ${#failed[@]} -eq 0 ]; then
    ok "all steps completed"
else
    warn "these steps failed and can be re-run individually: ${failed[*]}"
    exit 1
fi
