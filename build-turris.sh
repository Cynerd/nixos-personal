#!/bin/sh
omnia_hash="17b62c338f2a0862a58bb6951556beecd98ccda9"
moxes=( "spt-mox2" )
omnias=( "spt-omnia" )

cd "${0%/*}" || exit
for system in "${moxes[@]}"; do
	echo "Building $system"
	nix build -o "result-${system}" ".#nixosConfigurations.${system}.config.system.build.toplevel"
done
for system in "${omnias[@]}"; do
	echo "Building $system"
	nix build \
		--override-input nixpkgs "github:NixOS/nixpkgs/${omnia_hash}" \
		--override-input nixturris/nixpkgs "github:NixOS/nixpkgs/${omnia_hash}" \
		-o "result-${system}" \
		".#nixosConfigurations.${system}.config.system.build.toplevel"
done
