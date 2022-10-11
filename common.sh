# Common Bash functions for helper scripts in this repository
set -eu

## Logging #####################################################################
_print() {
	local color="\e[$1m"
	local clrcolor="\e[0m"
	shift
	if [ ! -t 1 ]; then
		color=""
		clrcolor=""
	fi
	printf "${color}%s${clrcolor}\n" "$*" >&2
}

stage() {
	_print '1;32' "$@"
}

info() {
	_print '1;35' "$@"
}

error() {
	_print '1;31' "$@"
}
warning() {
	_print '1;33' "$@"
}

## SSH access helper ###########################################################

# Convert hostname to the SSH destination
sshdest() {
	awk -F- 'NF > 1 { print $2"."$1; exit } { print $1 }' <<<"$1"
}

# Reverse opeartion for sshdest
sshhost() {
	awk -F. 'NF > 1 { print $2"-"$1; exit } { print $1 }' <<<"$1"
}

_sh() {
	if [ $# -gt 1 ]; then
		"$@"
	else
		sh -c "$1"
	fi
}

_ssh() {
	local device="$1"
	shift
	if [ "$device" != "$(hostname)" ]; then
		ssh "$(sshdest "$device")" -- "$@"
	else
		_sh "$@"
	fi
}

_tssh() {
	local device="$1"
	shift
	if [ "$device" != "$(hostname)" ]; then
		ssh -t "$(sshdest "$device")" -- "$@"
	else
		_sh "$@"
	fi
}

## Evalutions and queries ######################################################

# The path where build result is linked to
result() {
	echo ".result-$1"
}

# Get system of the device
device_system() {
	nix eval --raw ".#nixosConfigurations.$1.config.nixpkgs.system"
}

# Validates if link is valid.
build_validate() {
	local device="$1"
	[ -L "$(result "$device")" ] && [ -e "$(result "$device")" ]
}

## Build NixOS system ##########################################################
# $1: device name
# All other arguments are passed to the nix build command
build() {
	local device="$1"
	shift

	local toplevel=".config.system.build.toplevel"
	if [ "$(device_system "$device")" = "armv7l-linux" ]; then
		toplevel=".config.system.build.cross.x86_64-linux${toplevel}"
	fi
	if [ "$(device_system "$device")" = "aarch64-linux" ]; then
		toplevel=".config.system.build.cross.x86_64-linux${toplevel}"
	fi

	stage "Building system for device: $device"
	nix build \
		-o "$(result "${device}")" \
		--keep-going \
		"$@" \
		"${0%/*}#nixosConfigurations.${device}${toplevel}"
}

## Copy NixOS system ###########################################################
# $1: device name
copy() {
	local device="$1"
	if ! build_validate "$device"; then
		warning "System for device '$device' seems to be not build." >&2
		return 1
	fi
	local store
	store="$(readlink -f "$(result "$device")")"

	local freespace required;
	freespace="$(_ssh "$device" df -B 1 /nix | awk 'NR == 2 { print $4 }')"
	required="$(nix path-info -S "$store" | awk '{ print $2 }')"
	info "Free space on device: $(numfmt --to=iec "$freespace")"
	info "Required space: $(numfmt --to=iec "$required")"
	if [ "$required" -ge "$freespace" ]; then
		error "There is not enough space to copy clousure to: $device" >&2
		return 1
	fi

	stage "Copy closure to: $device"
	nix copy -s --to "ssh://$(sshdest "$device")" "$store"
}

## Switch Nix encironment ######################################################
# $1: switch operation to be performed
# $2: device name
# TODO possibly really query if switch is or is not required
setenv() {
	local switchop="$1"
	local device="$2"
	if ! build_validate "$device"; then
		warning "System '$device' seems to be not build." >&2
		return 1
	fi
	local store
	store="$(readlink -f "$(result "$device")")"

	stage "${switchop^} system: $device"
	local cursystem
	cursystem="$(_ssh "$device" readlink -f /nix/var/nix/profiles/system)"
	if [ "$cursystem" != "$store" ]; then
		info "-----------------------------------------------------------------"
		_ssh "$device" \
			nix store diff-closures "$cursystem" "$store"
		info "-----------------------------------------------------------------"
		# TODO we should call here switch-to-configuration as well to use single
		# sudo session and remove one prompt.
		local _store _switchop
		printf -v _store '%q' "$store"
		printf -v _switchop '%q' "$switchop"
		_tssh "$device" "sudo '$_store/bin/nixos-system' -s '$_switchop'"
	else
		warning "The latest system might have been already set."
	fi
}

boot() {
	setenv boot "$1"
}

switch() {
	setenv switch "$1"
}

switch_test() {
	setenv test "$1"
}
