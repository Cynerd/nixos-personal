{
  description = "Cynerd's personal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";

    sterm.url = "github:wentasah/sterm";
    agenix.url = "github:ryantm/agenix";
    shvspy.url = "git+https://github.com/silicon-heaven/shvspy.git?submodules=1";
    flatline.url = "git+http://gitlab.elektroline.cz/elektroline/flatlineng.git?submodules=1";
    shvcli.url = "git+https://gitlab.com/elektroline-predator/shvcli.git";

    #nixturris.url = "github:cynerd/nixturris";
    nixturris.url = "git+https://gitlab.com/cynerd/nixturris?ref=new-ci";
    nixbigclown.url = "github:cynerd/nixbigclown";
    vpsadminos.url = "github:vpsfreecz/vpsadminos";

    shellrc.url = "git+https://git.cynerd.cz/shellrc";
    usbkey.url = "git+https://gitlab.com/cynerd/usbkey.git/";
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
