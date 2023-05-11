{
  description = "Cynerd's personal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";

    agenix.url = "github:ryantm/agenix";
    shvspy.url = "git+https://github.com/silicon-heaven/shvspy.git?submodules=1";

    nixturris = {
      url = "github:cynerd/nixturris";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixbigclown.url = "github:cynerd/nixbigclown";
    vpsadminos.url = "github:vpsfreecz/vpsadminos";

    shellrc.url = "git+https://git.cynerd.cz/shellrc";
    sterm.url = "github:wentasah/sterm";
    usbkey.url = "git+https://git.cynerd.cz/usbkey?ref=modules";
  };

  outputs = {
    self,
    nixpkgs,
    nix,
    nixos-hardware,
    flake-utils,
    shellrc,
    ...
  }:
    with flake-utils.lib;
      {
        lib = import ./lib nixpkgs.lib;
        overlays.default = final: import ./pkgs;
        nixosModules = import ./nixos self;
        nixosConfigurations = import ./nixos/configurations.nix self;
      }
      // eachDefaultSystem (system: let
        pkgs = nixpkgs.legacyPackages."${system}".appendOverlays [
          shellrc.overlays.default
        ];
      in {
        packages = filterPackages system (flattenTree (import ./pkgs pkgs));
        legacyPackages = pkgs.extend self.overlays.default;
        devShells = filterPackages system (import ./devShells pkgs);
        formatter = pkgs.alejandra;
      });
}
