#!/usr/bin/env bash

# Switch to the US keyboard (to make sure that we have the correct one)
swaymsg input type:keyboard xkb_layout us

resolution="$(swaymsg -t get_outputs \
	| jq -r '.[0].rect | [.width,.height] | join("x")')"
case "$resolution" in
	1920x1080|2560x1440|2560x1600)
		;;
	*)
		resolution="1920x1080"
		;;
esac

exec swaylock -f \
	-n -c 000000 \
	-i "$(shuf -n1 -e "$BACKGROUND_LNXPCS"/*"$resolution.png")" \
	-s fill
