{
  description = "Cynerd's personal flake";

  inputs = {
    shellrc.url = "git+https://git.cynerd.cz/shellrc";
    nixturris.url = "git+https://git.cynerd.cz/nixturris";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";

    #sterm.url = "github:wentasah/sterm";
    sterm.url = "github:cynerd/sterm/comp";
  };

  outputs = { self
    , nixpkgs, flake-utils
    , shellrc, nixturris, personal-secret
    , sterm
  }:
    with flake-utils.lib;
    {
      overlays.default = final: prev: import ./pkgs { nixpkgs = prev; };
      nixosModules = import ./nixos nixpkgs;

      nixosConfigurations = let 

        modules = hostname: [
          self.nixosModules.default
          self.nixosModules."machine-${hostname}"
          shellrc.nixosModules.default
          (personal-secret.lib.personalSecrets hostname)
          {
            networking.hostName = hostname;
            nixpkgs.overlays = [
              self.overlays.default
              sterm.overlay
            ];
          }
        ];

        genericSystem = system: hostname: {
          ${hostname} = nixpkgs.lib.nixosSystem {
            system = system;
            modules = modules hostname;
          };
        };
        amd64System = genericSystem "x86_64-linux";
        armv7lSystem = genericSystem "armv7l-linux";
        aarch64System = genericSystem "aarch64-linux";

        turrisSystem = board: hostname: {
          ${hostname} = nixturris.lib.nixturrisSystem {
            nixpkgs = nixpkgs;
            board = board;
            modules = modules hostname;
          };
        };
        turrisMoxSystem = turrisSystem "mox";
        turrisOmniaSystem = turrisSystem "omnia";

      in
        amd64System "albert" //
        amd64System "binky" //
        amd64System "errol" //
        amd64System "lipwig" //
        amd64System "ridcully" //
        amd64System "susan" //
        armv7lSystem "spt-mpd" //
        aarch64System "adm-mpd" //
        turrisOmniaSystem "spt-omnia" //
        turrisMoxSystem "spt-mox" //
        turrisMoxSystem "spt-mox2" //
        turrisOmniaSystem "adm-omnia" //
        turrisOmniaSystem "adm-omnia2";

    } // eachDefaultSystem (system: {
      packages = filterPackages system (flattenTree (
        import ./pkgs { nixpkgs = nixpkgs.legacyPackages."${system}"; }
      ));
      devShells = filterPackages system
        (import ./develop { inherit nixpkgs; inherit shellrc; inherit system; });
    });

}
