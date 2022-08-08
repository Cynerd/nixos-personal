{
  description = "Cynerd's personal flake";

  inputs = {
    shellrc.url = "git+https://git.cynerd.cz/shellrc";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";
    nixturris = {
      url = "git+https://git.cynerd.cz/nixturris";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sterm.url = "github:wentasah/sterm";
  };

  outputs = { self
    , nixpkgs, flake-utils
    , shellrc, nixturris, personal-secret
    , sterm
  }:
    with flake-utils.lib;
    {
      overlays.default = final: prev: import ./pkgs { inherit self; nixpkgs = prev; };
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

        genericSystem = {system, extra_modules ? []}: hostname: {
          ${hostname} = nixpkgs.lib.nixosSystem {
            system = system;
            modules = (modules hostname) ++ extra_modules;
          };
        };
        amd64System = genericSystem {system = "x86_64-linux";};
        armv7lSystem = genericSystem {system = "armv7l-linux"; extra_modules = [
          nixturris.nixosModules.turris-crossbuild
          nixturris.nixosModules.armv7l-overlay
        ];};
        aarch64System = genericSystem {system = "aarch64-linux";};

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
        turrisMoxSystem "dean" //
        turrisOmniaSystem "spt-omnia" //
        turrisMoxSystem "spt-mox" //
        turrisMoxSystem "spt-mox2" //
        turrisOmniaSystem "adm-omnia" //
        turrisOmniaSystem "adm-omnia2";

    } // eachDefaultSystem (system: {
      packages = filterPackages system (flattenTree (
        import ./pkgs { inherit self; nixpkgs = nixpkgs.legacyPackages."${system}"; }
      ));
      devShells = filterPackages system
        (import ./devShells { inherit nixpkgs; inherit shellrc; inherit system; });
    });

}
