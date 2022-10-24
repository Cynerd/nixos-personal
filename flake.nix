{
  description = "Cynerd's personal flake";

  inputs = {
    shellrc.url = "git+https://git.cynerd.cz/shellrc";
    personal-secret.url = "git+ssh://git@cynerd.cz/nixos-personal-secret";
    nixturris = {
      url = "git+https://git.cynerd.cz/nixturris";
      #url = "/home/cynerd/projects/nixturris";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vpsadminos.url = "github:vpsfreecz/vpsadminos";

    sterm.url = "github:wentasah/sterm";
    usbkey.url = "git+https://git.cynerd.cz/usbkey?ref=modules";
  };

  outputs = { self
    , nixpkgs, flake-utils, nixos-hardware, nix
    , shellrc, usbkey, nixturris, personal-secret
    , vpsadminos
    , sterm
  }:
    with flake-utils.lib;
    {
      overlays.default = final: prev: import ./pkgs { inherit self; nixpkgs = prev; };
      nixosModules = import ./nixos self;

      nixosConfigurations = let 

        modules = hostname: [
          self.nixosModules.default
          self.nixosModules."machine-${hostname}"
          shellrc.nixosModules.default
          usbkey.nixosModules.default
          (personal-secret.lib.personalSecrets hostname)
          {
            networking.hostName = hostname;
            nixpkgs.overlays = [
              self.overlays.default
              sterm.overlay
            ];
          }
        ];

        genericSystem = {system ? "x86_64-linux", extra_modules ? []}:
          hostname: {
            ${hostname} = nixpkgs.lib.nixosSystem {
              system = system;
              modules = (modules hostname) ++ extra_modules;
            };
          };
        amd64System = genericSystem { };
        vpsSystem = genericSystem {
          extra_modules = [
            vpsadminos.nixosConfigurations.container
            { boot.loader.systemd-boot.enable = false; }
          ];
        };
        raspi2System = genericSystem {
          system = "armv7l-linux";
          extra_modules = [
            nixos-hardware.nixosModules.raspberry-pi-2
            nixturris.nixosModules.turris-crossbuild
            nixturris.nixosModules.armv7l-overlay
            { boot.loader.systemd-boot.enable = false; }
            { nixpkgs.overlays = [ (final: super: {
                makeModulesClosure = x:
                  super.makeModulesClosure (x // { allowMissing = true; });
              })]; }
          ];
        };
        raspi3System = genericSystem {
          system = "aarch64-linux";
          extra_modules = [
            nixturris.nixosModules.turris-crossbuild
            ({pkgs, ...}: {
              boot.loader.systemd-boot.enable = false;
              boot.loader.grub.enable = false;
              boot.loader.generic-extlinux-compatible.enable = true;
              #boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;
            })
          ];
        };
        beagleboneSystem = genericSystem {
          system = "armv7l-linux";
          extra_modules = [
            nixturris.nixosModules.turris-crossbuild
            nixturris.nixosModules.armv7l-overlay
            # TODO
          ];
        };

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
        amd64System "ridcully" //
        amd64System "susan" //
        vpsSystem "lipwig" //
        vpsSystem "mrpump" //
        raspi2System "spt-mpd" //
        raspi3System "adm-mpd" //
        beagleboneSystem "gaspode" //
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
