#!/usr/bin/env bash
set -eu
declare -a devices
declare -A sshmap
################################################################################
omnia_hash="bd7ac5d8c08538ec1f126d34b765f0362427fe17"
## aarch64
# Mox
devices+=( "dean" "spt-mox2" )
sshmap["spt-mox2"]="mox2.spt"
# Raspberry Pi
devices+=( "adm-mpd" )
sshmap["adm-mpd"]="mpd.adm"

## armv7
# Omnia
devices+=( "spt-omnia" )
sshmap["spt-omnia"]="omnia.spt"
# Raspberry Pi
devices+=( "spt-mpd" )
sshmap["spt-mpd"]="mpd.spt"
################################################################################

valid_device() {
	local check="$1"
	for dev in "${devices[@]}"; do
		[ "$dev" != "$check" ] \
			|| return 0
	done
	return 1
}


build() {
	local system="$1"
	echo "Building $system"
	local -a args
	local toplevel=".config.system.build.toplevel"
	args+=("--keep-going")
	args+=("--override-input" "nixturris" "/home/cynerd/projects/nixturris")
	if [[ "$system" == *omnia ]]; then
		true
		#toplevel=".config.system.build.cross.x86_64-linux${toplevel}"
		#args=( \
		#	"--override-input" "nixpkgs" "github:NixOS/nixpkgs/${omnia_hash}"
		#	"--override-input" "nixturris/nixpkgs" "github:NixOS/nixpkgs/${omnia_hash}"
		#)
	fi
	nix build \
		-o "result-${system}" \
		"${args[@]}" \
		"${0%/*}#nixosConfigurations.${system}${toplevel}"
}

build_validate() {
	local system="$1"
	[ -L "result-$system" ] && [ ! -e "result-$system" ]
}

copy() {
	local system="$1"
	if ! build_validate "$system"; then
		echo "System '$system' seems to be not build." >&2
		return 1
	fi
	local store="$(readlink -f "result-$system")"
	local host="${sshmap["$system"]:-$system}"

	local freespace="$(ssh "$host" -- df -B 1 /nix | awk 'NR == 2 { print $4 }')"
	local required="$(nix path-info -S "$store")"
	if [ "$required" -ge "$freespace" ]; then
		echo "There is not enough space to copy clousure to: $system" >&2
		return 1
	fi

	echo "Copy closure to: $system"
	nix copy -s --to "ssh://$host" "$store"
}

setenv() {
	local system="$1"
	if ! build_validate "$system"; then
		echo "System '$system' seems to be not build." >&2
		return 1
	fi
	local store="$(readlink -f "result-$system")"
	local host="${sshmap["$system"]:-$system}"

	echo "Update system: $system"
	if [ "$(ssh "$host" -- readlink -f /nix/var/nix/profiles/system)" != "$store" ]; then
		ssh -t "$host" -- \
			sudo nix-env --profile /nix/var/nix/profiles/system --set "$store"
	fi
}

boot() {
	local system="$1"
	setenv "$system" || return 1

	local store="$(readlink -f "result-$system")"
	local host="${sshmap["$system"]:-$system}"

	echo "Setting boot system: $system"
	ssh -t "$host" -- \
		sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot
}

is_current() {
	ssh "$1" -- \
		'[ "$(readlink -f /run/current-system)" != "$(readlink -f /nix/var/nix/profiles/system)" ]'
}

switch() {
	local system="$1"
	setenv "$system" || return 1

	local store="$(readlink -f "result-$system")"
	local host="${sshmap["$system"]:-$system}"

	if is_current "$host"; then
		echo "Switching: $system"
		ssh -t "$host" -- \
			sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
	else
		echo "This system is already running: $system"
	fi
}

switch_test() {
	local system="$1"
	setenv "$system" || return 1

	local store="$(readlink -f "result-$system")"
	local host="${sshmap["$system"]:-$system}"

	if is_current "$host"; then
		echo "Testing: $system"
		ssh -t "$host" -- \
			sudo /nix/var/nix/profiles/system/bin/switch-to-configuration test
	else
		echo "This system is already running: $system"
	fi
}

for_devices() {
	for device in "${selected_devices[@]}"; do
		for op in "$@"; do
			if ! "$op" "$device"; then
				echo "Operation '$op' failed for: $device" >&2
				break
			fi
		done
	done
}


operation="${1:-}"
[ $# -gt 0 ] && shift

declare -a selected_devices
if [ $# -gt 0 ]; then
	for device in "$@"; do
		if ! valid_device "$device"; then
			echo "No such device: $device" >&2
			exit 2
		fi
		selected_devices+=("$device")
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
