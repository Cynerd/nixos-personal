#!/bin/sh
set -eu
hostname="${1:-$(hostname)}"

if [ "$(id -u)" -ne 0 ]; then
	echo "Please run as root!" >&2
	exit 1
fi

if [ "$hostname" = "nixos" ]; then
	echo "The hostname is the default one, that is not right for sure." >&2
	echo "Please specify the correct hostname as the first argument!" >&2
	exit 1
fi

if [ ! -s /.personal-secrets.key ]; then
	echo "Please paste the personal secret key (terminate using ^D)" >&2
	cat >/.personal-secrets.key
fi

mkdir -p ~/.ssh
cat >~/.ssh/config <<EOF
Match User git Host cynerd.cz
	IdentityFile ~/.ssh/nixos-secret-access
EOF
echo "Please paste the SSH access key now (terminate using ^D):" >&2
cat >~/.ssh/nixos-secret-access
trap "rm -f ~/.ssh/nixos-secret-access" EXIT

nix-shell -p git --command \
	"nixos-rebuild switch --flake 'git+https://git.cynerd.cz/nixos-personal#$hostname' --fast"
