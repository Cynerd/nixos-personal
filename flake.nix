{
  description = "Cynerd's personal flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "nixos-hardware";
    nixdeploy.url = "gitlab:cynerd/nixdeploy";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";

    agenix.url = "github:ryantm/agenix";
    shvspy.url = "git+https://github.com/silicon-heaven/shvspy.git?submodules=1";
    flatline.url = "git+https://gitlab.elektroline.cz/elektroline/flatlineng.git?submodules=1";
    shvcli.url = "github:silicon-heaven/shvcli";

    nixturris.url = "gitlab:cynerd/nixturris";
    nixbigclown.url = "github:cynerd/nixbigclown";
    vpsadminos.url = "github:vpsfreecz/vpsadminos";

    shellrc.url = "git+https://git.cynerd.cz/shellrc";
    usbkey.url = "gitlab:cynerd/usbkey";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    agenix,
    shvspy,
    flatline,
    shvcli,
    nixdeploy,
    shellrc,
    usbkey,
    ...
  }: let
    inherit (flake-utils.lib) eachDefaultSystem filterPackages;
    inherit (nixpkgs.lib) mapAttrs' nameValuePair filterAttrs;
  in
    {
      lib = import ./lib nixpkgs.lib;
      overlays = {
        noInherit = final: prev: import ./pkgs final prev;
        default = nixpkgs.lib.composeManyExtensions [
          agenix.overlays.default
          shvspy.overlays.default
          flatline.overlays.default
          shvcli.overlays.default
          nixdeploy.overlays.default
          shellrc.overlays.default
          usbkey.overlays.default
          self.overlays.noInherit
        ];
      };
      nixosModules = import ./nixos self;
      nixosConfigurations = import ./nixos/configurations.nix self;
    }
    // eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages."${system}".extend self.overlays.default;
    in {
      packages = {
        default = pkgs.nixdeploy;
      } // mapAttrs' (n: v:
        nameValuePair
        "tarball-${n}"
        v.buildPlatform.${system}.config.system.build.tarball) (filterAttrs
        (n: v: v.config.system.build ? tarball)
        self.nixosConfigurations);
      legacyPackages = pkgs;
      devShells = filterPackages system (import ./devShells pkgs);
      formatter = pkgs.alejandra;
    });
}
