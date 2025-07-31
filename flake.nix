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
    systems,
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
    inherit (nixpkgs.lib) genAttrs mapAttrs' nameValuePair filterAttrs;
    forSystems = genAttrs (import systems);
    withPkgs = func: forSystems (system: func self.legacyPackages.${system});

    osFilterMap = system: attr:
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

    legacyPackages =
      forSystems (system:
        nixpkgs.legacyPackages.${system}.extend self.overlays.default);

    packages = forSystems (
      system:
        {inherit (nixosdeploy.packages.${system}) default;}
        // (osFilterMap "toplevel")
        // (osFilterMap "tarball")
        // (osFilterMap "firmware")
    );

    devShells = withPkgs (import ./devShells);

    formatter = withPkgs (pkgs: pkgs.alejandra);
  };
}
