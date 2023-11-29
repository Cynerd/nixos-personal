{
  description = "Cynerd's personal flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
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
