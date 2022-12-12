{
  description = "Cynerd's personal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";

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

  outputs = { self, nixpkgs, nix, nixos-hardware, flake-utils, shellrc, ... }:
    with flake-utils.lib;
    {
      overlays.default = final: prev: import ./pkgs { inherit self; nixpkgs = prev; };
      nixosModules = import ./nixos self;
      nixosConfigurations = import ./nixos/configurations.nix self;
    } // eachDefaultSystem (system: {
      packages = filterPackages system (flattenTree (
        import ./pkgs { inherit self; nixpkgs = nixpkgs.legacyPackages."${system}"; }
      ));
      devShells = filterPackages system
        (import ./devShells { inherit nixpkgs; inherit shellrc; inherit system; });
    });

}
