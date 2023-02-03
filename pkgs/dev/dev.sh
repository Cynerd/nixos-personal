#!/usr/bin/env bash
set -eu

target="${1:-}"
shift

declare -a nixargs
known_shells="$(tr ':' '\n' <<<"${DEV_SHELLS:-}")"
while IFS='=' read name drv res; do
	if [ "$target" == "$name" ]; then
		target="$drv"
		# Note: no network should be needed as this should be available
		nixargs+=("--offline")
		break
	fi
done <<<"$known_shells"

exec nix "${nixargs[@]}" develop "$target" -c zsh "$@"
