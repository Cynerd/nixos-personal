#!/usr/bin/env bash
set -eu
omnia_hash="bd7ac5d8c08538ec1f126d34b765f0362427fe17"
routers=( "dean" "spt-mox2" "spt-omnia" )

cd "${0%/*}" || exit
for system in "${routers[@]}"; do
	echo "Building $system"
	declare -a args
	toplevel=".config.system.build.toplevel"
	if [[ "$system" == *omnia ]]; then
		toplevel=".config.system.build.cross.x86_64-linux${toplevel}"
		args=( \
			"--override-input" "nixpkgs" "github:NixOS/nixpkgs/${omnia_hash}"
			"--override-input" "nixturris/nixpkgs" "github:NixOS/nixpkgs/${omnia_hash}"
			"--override-input" "nixturris" "/home/cynerd/projects/nixturris"
		)
	fi
	nix build \
		-o "result-${system}" \
		"${args[@]}" \
		".#nixosConfigurations.${system}${toplevel}"
done
