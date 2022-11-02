#!/usr/bin/env bash
set -eu

target="$1"
shift

known_shells="$(tr ':' '\n' <<<"${DEV_SHELLS:-}")"
while IFS='=' read name drv res; do
	if [ "$target" == "$name" ]; then
		target="$drv#$name"
		break
	fi
done <<<"$known_shells"

exec nix develop "$target" -c zsh "$@"
