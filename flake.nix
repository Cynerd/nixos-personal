{
  description = "Cynerd's personal flake";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
    nixos-hardware.url = "nixos-hardware";
    nixosdeploy.url = "gitlab:cynerd/nixosdeploy";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";
    shellrc.url = "git+https://git.cynerd.cz/shellrc";

    agenix.url = "github:ryantm/agenix";
    shvcli.url = "github:silicon-heaven/shvcli";
    shvcli-ell.url = "gitlab:elektroline-predator/shvcli-ell";

    usbkey.url = "gitlab:cynerd/usbkey";

    nixturris.url = "gitlab:cynerd/nixturris";
    vpsadminos.url = "github:vpsfreecz/vpsadminos";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nixosdeploy,
    personal-secret,
    shellrc,
    agenix,
    shvcli,
    shvcli-ell,
    usbkey,
    nixturris,
    ...
  }: let
    inherit (flake-utils.lib) eachDefaultSystem filterPackages;
    inherit (nixpkgs.lib) mapAttrs' nameValuePair filterAttrs;
  in
    {
      overlays = {
        lib = final: prev: import ./lib final prev;
        pkgs = final: prev: import ./pkgs final prev;
        default = nixpkgs.lib.composeManyExtensions [
          agenix.overlays.default
          nixosdeploy.overlays.default
          self.overlays.pkgs
          shellrc.overlays.default
          shvcli.overlays.default
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
      lib = import ./lib nixpkgs.lib;
    }
    // eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages."${system}".extend self.overlays.default;

      osFilterMap = attr:
        mapAttrs' (n: v: let
          os =
            if v.config.nixpkgs.hostPlatform.system == system
            then v
            else (v.extendModules {modules = [{nixpkgs.buildPlatform.system = system;}];});
        in
          nameValuePair "${attr}-${n}" os.config.system.build."${attr}")
        (filterAttrs (_: v: v.config.system.build ? "${attr}")
          self.nixosConfigurations);
    in {
      packages =
        {inherit (nixosdeploy.packages.${system}) default;}
        // (osFilterMap "toplevel")
        // (osFilterMap "tarball")
        // (osFilterMap "firmware");
      legacyPackages = pkgs;
      devShells = filterPackages system (import ./devShells pkgs);
      formatter = pkgs.alejandra;
    });
}
