#!/usr/bin/env bash
source "${0%/*}/tools/common.sh"
declare -a default_hosts
################################################################################
## x86_64
# Desktops
default_hosts+=( "errol" "ridcully" )
# VPSFree
default_hosts+=( "lipwig" )

## aarch64
# Mox
default_hosts+=( "dean" "spt-mox" "spt-mox2" )
# Raspberry Pi
default_hosts+=( "adm-mpd" )

## armv7
# Omnia
default_hosts+=( "spt-omnia" "adm-omnia" "adm-omnia2" )
# Raspberry Pi
default_hosts+=( "spt-mpd" )

################################################################################
operation="${1:-}"
[ $# -gt 0 ] && shift

declare -a selected_hosts
if [ $# -gt 0 ]; then
	for host in "$@"; do
		selected_hosts+=("$(sshhost "$host")")
	done
else
	selected_hosts=("${default_hosts[@]}")
fi


for_hosts() {
	for host in "${selected_hosts[@]}"; do
		for op in "$@"; do
			if ! "$op" "$host"; then
				error "Operation '$op' failed for: $host" >&2
				break
			fi
		done
	done
}


case "$operation" in
	help|h)
		cat <<-EOF
		Usage $0 operation [host]...
		Local system builder and updater for remote hosts.

		Operations:
		  build: build host system
		  copy: copy built system to the host
		  boot: set built system to be boot default on the host
		  switch: switch to the built system on the target host
		  test: test the built system on the target host
		EOF
		;;
	build|b|"")
		for_hosts build
		;;
	copy|c)
		for_hosts copy
		;;
	boot)
		for_hosts boot
		;;
	switch|s)
		for_hosts switch
		;;
	test|t)
		for_hosts switch_test
		;;
	build-copy|bc)
		for_hosts build copy
		;;
	build-switch|bs)
		for_hosts build copy switch
		;;
	build-test|bt)
		for_hosts build copy switch_test
		;;
	build-boot|bb)
		for_hosts build copy boot
		;;
	*)
		echo "Unknown operation: $operation" >&2
		exit 2
		;;
esac
