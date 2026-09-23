{
  description = "Cynerd's personal flake";

  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "flake:nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "nixos-hardware";
    nixosdeploy.url = "gitlab:cynerd/nixosdeploy";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";
    shellrc.url = "git+https://git.cynerd.cz/shellrc";

    agenix.url = "github:ryantm/agenix";
    pyshv.url = "github:silicon-heaven/pyshv";
    shvcli.url = "github:silicon-heaven/shvcli";
    shvcli-ell.url = "gitlab:elektroline-predator/shvcli-ell";

    usbkey.url = "gitlab:cynerd/usbkey";

    nixturris.url = "gitlab:cynerd/nixturris";
    vpsadminos.url = "github:vpsfreecz/vpsadminos";
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    nixosdeploy,
    personal-secret,
    shellrc,
    agenix,
    pyshv,
    shvcli,
    shvcli-ell,
    usbkey,
    nixturris,
    ...
  }: let
    inherit (nixpkgs.lib) genAttrs;
    inherit (nixosdeploy.lib) nixosFilterHostBuilds;
    forSystems = genAttrs (import systems);
    withPkgs = func: forSystems (system: func self.legacyPackages.${system});
  in {
    overlays = {
      lib = import ./lib;
      pkgs = import ./pkgs;
      default = nixpkgs.lib.composeManyExtensions [
        agenix.overlays.default
        nixosdeploy.overlays.default
        self.overlays.pkgs
        shellrc.overlays.default
        pyshv.overlays.default
        shvcli.overlays.packages
        shvcli-ell.overlays.packages
        usbkey.overlays.default
      ];
    };

    nixosModules = import ./nixos/modules {
      inherit (nixpkgs) lib;
      default_modules = [
        nixosdeploy.nixosModules.default
        nixturris.nixosModules.default
        personal-secret.nixosModules.default
        shellrc.nixosModules.default
        usbkey.nixosModules.default
      ];
    };

    nixosConfigurations = import ./nixos/configurations self;

    legacyPackages =
      forSystems (system:
        nixpkgs.legacyPackages.${system}.extend self.overlays.default);

    packages = forSystems (
      system:
        {inherit (nixosdeploy.packages.${system}) default;}
        // (nixosFilterHostBuilds self.nixosConfigurations [
            "toplevel"
            "tarball"
            "firmware"
          ]
          system)
    );

    devShells = withPkgs (import ./devShells);

    formatter = withPkgs (pkgs: pkgs.alejandra);
  };
}
