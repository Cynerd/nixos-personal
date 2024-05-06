#!/usr/bin/env bash
set -eu

target="${1:-.}"
[[ $# -eq 0 ]] || shift

declare -a nixargs
while IFS='=' read -r name drv _; do
	if [ "$target" == "$name" ]; then
		target="$drv^*"
		# Note: no network should be needed as this should be available
		nixargs+=("--offline")
		break
	fi
done < <(tr ':' '\n' <<<"${DEV_SHELLS:-}")

exec nix "${nixargs[@]}" develop "$target" -c zsh "$@"
