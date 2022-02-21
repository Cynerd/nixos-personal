#!/usr/bin/env bash

_background() {
	local resolution="${1:-1920x1080}"
	case "$resolution" in
		1920x1080|2560x1440|2560x1600)
			;;
		*)
			resolution="1920x1080"
			;;
	esac
	find "$BACKGROUND_LNXPCS" -type f -name "*-$resolution.png" | shuf -n 1
}

background() {
	local width="$1"
	local height="$2"
	local res
	res="$(_background "${width}x${height}")"
	if [ -n "$res" ]; then
		res="$(_background)"
	fi
	echo "$res"
}

set_backgrounds() {
	local ipc="$1"
	swaymsg -t get_outputs | jq -r '.[] | [.name,.rect.width,.rect.height] | join(",")' \
		| while IFS=, read -r name width height; do
			swaymsg $ipc \
				output "$name" \
				background "$(background "$width" "$height")" fill
		done
}

if [ -n "$WAYLAND_DISPLAY" ]; then
	set_backgrounds
else
	find "/run/user/$(id -u)/" -name "sway-ipc*" \
		| while read -r ipc; do
			set_backgrounds "-s '$ipc'"
		done
fi
