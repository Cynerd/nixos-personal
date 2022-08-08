#!/bin/sh
set -eu
hostname="${1:-$(hostname)}"
root="${2:-}"

_sudo() {
	if [ "$(id -u)" -ne 0 ]; then
		"$@"
	else
		sudo -p 'Sudo password: ' -- "$@"
	fi
}

if [ "$hostname" = "nixos" ]; then
	echo "The hostname is the default one, that is not right for sure." >&2
	echo "Please specify the correct hostname as the first argument!" >&2
	exit 1
fi

if [ ! -s "$root/.personal-secrets.key" ]; then
	echo "Please paste the personal secret key (terminate using ^D)" >&2
	sudo tee "$root/.personal-secrets.key" >/dev/null
fi

eval "$(ssh-agent)"
echo "Please paste the SSH access key now (terminate using ^D):" >&2
ssh-add -
trap 'kill "$SSH_AGENT_PID"' EXIT

flake="git+https://git.cynerd.cz/nixos-personal#$hostname"
if [ -z "$root" ]; then
	nix shell nixpkgs\#git --command \
		"_sudo \"\$(command -v nixos-rebuild)\" switch --flake '$flake' --fast"
else
	nix shell nixpkgs\#git nixpkgs\#nixos-install-tools --command \
		"_sudo \"\$(command -v nixos-install)\" --flake '$flake' --root '$root'"
fi
