#!/bin/sh
set -eu
hostname="$1"
root="${2:-$(pwd)}"
src="$(readlink -f "${0%/*}")"

if [ "$(id -u)" -ne 0 ]; then
	echo "Run this as root!" >&2
	exit 1
fi

if ! command -v git >/dev/null; then
	exec nix shell 'nixpkgs#git' -c "$0" "$@"
fi

if [ ! -s "$root/.personal-secrets.key" ]; then
	echo "Please paste the personal secret key (terminate using ^D)" >&2
	sudo tee "$root/.personal-secrets.key" >/dev/null
fi

if [ -f "$src/flake.nix" ]; then
	flake="$src"
else
	flake="git+https://git.cynerd.cz/nixos-personal"
	eval "$(ssh-agent)"
	echo "Please paste the SSH access key now (terminate using ^D):" >&2
	ssh-add -
	trap 'kill "$SSH_AGENT_PID"' EXIT
fi

buildSystem="$(nix eval --raw --impure --expr 'builtins.currentSystem')"
targetSystem="$(nix eval --raw "$flake#nixosConfigurations.$hostname.pkgs.system")"

toplevel="config.system.build.toplevel"
if [ "$buildSystem" != "$targetSystem" ]; then
	toplevel="config.system.build.cross.$buildSystem.$toplevel"
fi

if [ -f "$src/flake.nix" ]; then
	# Build in system when running from sources
	result="$(nix build --no-link --print-out-paths \
		"$flake#nixosConfigurations.$hostname.$toplevel")"
	nix copy --to "$root" "$result" 
else
	result="$(nix build --no-link --print-out-paths \
		"$flake#nixosConfigurations.$hostname.$toplevel" \
		--store "$root" --extra-substituters 'auto?trusted=1')"
fi

nix-env --store "$root" --extra-substituters 'auto?trusted=1' \
	-p "$root/nix/var/nix/profiles/system" --set "$result"

# Mark the target as a NixOS installation, otherwise switch-to-configuration will chicken out.
mkdir -m 0755 -p "$root/etc"
touch "$root/etc/NIXOS"

# Copy over binfmt runners if required
if [ "$buildSystem" != "$targetSystem" ]; then
	mkdir -p "$root/run/binfmt"
	for binfmt in /run/binfmt/*; do
		nix copy --to "$root" "$(readlink -f "$binfmt")" 
		ln -sf "$(readlink -f "$binfmt")" "$root/$binfmt"
	done
fi

ln -sfn /proc/mounts "$root/etc/mtab" # Grub needs an mtab.
NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root "$root" -- \
	/nix/var/nix/profiles/system/bin/switch-to-configuration boot
