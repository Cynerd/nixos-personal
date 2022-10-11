#!@shell@
# Simple script handy to be used for activation

while getopts "s" opt; do
	case "$opt" in
		s)
			if [ ! -v NIXOS_SYSTEM_GNU_SCREEN ]; then
				export NIXOS_SYSTEM_GNU_SCREEN=1
				exec @out@/sw/bin/screen "$0" "$@"
			fi
			;;
		*)
			echo "Invalid argument: $1" >&2
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))


@out@/sw/bin/nix-env --profile /nix/var/nix/profiles/system --set '@out@'

@out@/bin/switch-to-configuration "$@" || {
	echo "Switch failed!" >&2
	read -r _
	exit 1
}
