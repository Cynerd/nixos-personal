#!/usr/bin/env bash
set -eu

target="$1"
shift

known_shells="$(tr ':' '\n' <<<"${DEV_SHELLS:-}")"
while IFS='=' read name val; do
	if [ "$target" == "$name" ]; then
		target="$DEV_FLAKE#$name"
		break
	fi
done <<<"$known_shells"

exec nix develop "$target" -c zsh "$@"
