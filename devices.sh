#!/usr/bin/env bash
source "${0%/*}/common.sh"
declare -a devices
################################################################################
## aarch64
# Mox
devices+=( "dean" "spt-mox" "spt-mox2" )
# Raspberry Pi
devices+=( "adm-mpd" )

## armv7
# Omnia
devices+=( "spt-omnia" "adm-omnia" "adm-omnia2" )
# Raspberry Pi
devices+=( "spt-mpd" )
################################################################################

valid_device() {
	local check="$1"
	for dev in "${devices[@]}"; do
		[ "$dev" != "$check" ] \
			|| return 0
	done
	return 1
}

for_devices() {
	for device in "${selected_devices[@]}"; do
		for op in "$@"; do
			if ! "$op" "$device"; then
				error "Operation '$op' failed for: $device" >&2
				break
			fi
		done
	done
}

################################################################################
operation="${1:-}"
[ $# -gt 0 ] && shift

declare -a selected_devices
if [ $# -gt 0 ]; then
	for device in "$@"; do
		if valid_device "$device"; then
			selected_devices+=("$device")
		else
			asdev="$(sshhost "$device")"
			if valid_device "$asdev"; then
				selected_devices+=("$asdev")
			else
				error "No such device: $device" >&2
				exit 2
			fi
		fi
	done
else
	selected_devices=("${devices[@]}")
fi


case "$operation" in
	help|h)
		cat <<-EOF
		Usage $0 operation [device]...
		Local system builder and updater for remote devices.

		Operations:
		  build: build device system
		  copy: copy built system to the device
		  boot: set built system to be boot default on the device
		  switch: switch to the built system on the target device
		  test: test the built system on the target device
		EOF
		;;
	build|b|"")
		for_devices build
		;;
	copy|c)
		for_devices copy
		;;
	boot)
		for_devices boot
		;;
	switch|s)
		for_devices switch
		;;
	test|t)
		for_devices switch_test
		;;
	build-copy|bc)
		for_devices build copy
		;;
	build-switch|bs)
		for_devices build copy switch
		;;
	build-test|bt)
		for_devices build copy switch_test
		;;
	build-boot|bb)
		for_devices build copy boot
		;;
	default)
		echo "Unknown operation: $operation" >&2
		exit 2
		;;
esac
