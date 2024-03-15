{
  description = "Cynerd's personal flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "nixos-hardware";
    nixdeploy.url = "gitlab:cynerd/nixdeploy";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";
    shellrc.url = "git+https://git.cynerd.cz/shellrc";

    agenix.url = "github:ryantm/agenix";
    shvspy.url = "git+https://github.com/silicon-heaven/shvspy.git?submodules=1";
    shvcli.url = "github:silicon-heaven/shvcli";

    usbkey.url = "gitlab:cynerd/usbkey";

    nixturris.url = "gitlab:cynerd/nixturris";
    nixbigclown.url = "github:cynerd/nixbigclown";
    vpsadminos.url = "github:vpsfreecz/vpsadminos";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nixdeploy,
    personal-secret,
    shellrc,
    agenix,
    shvspy,
    shvcli,
    usbkey,
    nixturris,
    nixbigclown,
    ...
  }: let
    inherit (flake-utils.lib) eachDefaultSystem filterPackages;
    inherit (nixpkgs.lib) attrValues;
    revision = self.shortRev or self.dirtyShortRev or "unknown";
  in
    {
      overlays = {
        lib = final: prev: import ./lib prev;
        pkgs = final: prev: import ./pkgs final prev;
        default = nixpkgs.lib.composeManyExtensions [
          agenix.overlays.default
          nixdeploy.overlays.default
          self.overlays.pkgs
          shellrc.overlays.default
          shvcli.overlays.default
          shvspy.overlays.default
          usbkey.overlays.default
        ];
      };

      nixosModules = let
        modules = import ./nixos/modules {inherit (nixpkgs) lib;};
      in
        modules
        // {
          default = {
            imports =
              attrValues modules
              ++ [
                nixbigclown.nixosModules.default
                nixdeploy.nixosModules.default
                nixturris.nixosModules.default
                personal-secret.nixosModules.default
                shellrc.nixosModules.default
                usbkey.nixosModules.default
              ];
            config = {
              nixpkgs.overlays = [self.overlays.default];
              system.configurationRevision = revision;
            };
          };
        };

      nixosConfigurations = import ./nixos/configurations self;
      lib = import ./lib nixpkgs.lib;
    }
    // eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages."${system}".extend self.overlays.default;
    in {
      packages.default = pkgs.nixdeploy;
      legacyPackages = pkgs;
      devShells = filterPackages system (import ./devShells pkgs);
      formatter = pkgs.alejandra;
    });
}
