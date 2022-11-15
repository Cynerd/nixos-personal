#!/usr/bin/env bash
set -eu

target="${1:-}"
shift

declare -a nixargs
known_shells="$(tr ':' '\n' <<<"${DEV_SHELLS:-}")"
while IFS='=' read name drv res; do
	if [ "$target" == "$name" ]; then
		target="$drv"
		# Note: we do not need substituters as this should be build
		nixargs+=("--no-substitute")
		break
	fi
done <<<"$known_shells"

exec nix "${nixargs[@]}" develop "$target" -c zsh "$@"
