#!/usr/bin/env bash
source "${0%/*}/tools/common.sh"

operations() {
	for op in "$@"; do
		if ! "$op" "$(hostname)"; then
			error "Operation '$op' failed" >&2
			break
		fi
	done
}

################################################################################
operation="${1:-}"
if [ $# -gt 1 ]; then
	echo "Invalid argument: $2" >&2
	exit 2
fi

case "$operation" in
	help|h)
		cat <<-EOF
		Usage $0 operation [device]...
		Local system builder and updater for remote devices.

		Operations:
		  build: build device system
		  boot: set built system to be boot default on the device
		  switch: switch to the built system on the target device
		  test: test the built system on the target device
		EOF
		;;
	build|b)
		operations build
		;;
	boot)
		operations boot
		;;
	switch|s)
		operations switch
		;;
	test|t)
		operations switch_test
		;;
	build-switch|bs|"")
		operations build switch
		;;
	build-test|bt)
		operations build switch_test
		;;
	build-boot|bb)
		operations build boot
		;;
	default)
		echo "Unknown operation: $operation" >&2
		exit 2
		;;
esac
