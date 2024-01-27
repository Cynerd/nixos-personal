self:
with builtins;
with self.inputs.nixpkgs.lib; let
  inherit (self.inputs) nixpkgs nixos-hardware nixturris vpsadminos;

  modules = hostname:
    [
      self.nixosModules.default
      (self.inputs.personal-secret.lib.personalSecrets hostname)
      {
        networking.hostName = hostname;
        nixpkgs.overlays = [self.overlays.default];
        system.configurationRevision = self.rev or "dirty";
      }
    ]
    ++ (optional (hasAttr "machine-${hostname}" self.nixosModules) self.nixosModules."machine-${hostname}");
  specialArgs = {
    lib = nixpkgs.lib.extend (prev: final: import ../lib prev);
  };

  genericSystem = {
    system ? "x86_64-linux",
    extra_modules ? [],
  }: hostname: {
    ${hostname} = nixturris.lib.addBuildPlatform (nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules =
        (modules hostname)
        ++ extra_modules
        ++ [
          {
            nixpkgs.hostPlatform.system = system;
          }
        ];
    });
  };
  amd64System = genericSystem {};
  vpsSystem = genericSystem {
    extra_modules = [
      vpsadminos.nixosConfigurations.container
      {boot.loader.systemd-boot.enable = false;}
    ];
  };
  raspi2System = genericSystem {
    system = "armv7l-linux";
    extra_modules = [
      nixos-hardware.nixosModules.raspberry-pi-2
      ({pkgs, ...}: {
        boot.loader.systemd-boot.enable = false;
        boot.initrd.includeDefaultModules = false;
      })
    ];
  };
  raspi3System = genericSystem {
    system = "aarch64-linux";
    extra_modules = [
      ({pkgs, ...}: {
        boot = {
          kernelPackages = pkgs.linuxPackages_rpi3;
          initrd.includeDefaultModules = false;
          loader = {
            grub.enable = false;
            systemd-boot.enable = false;
            generic-extlinux-compatible.enable = true;
          };
        };
      })
    ];
  };
  beagleboneSystem = genericSystem {
    system = "armv7l-linux";
    extra_modules = [
      {
        boot.loader = {
          grub.enable = false;
          systemd-boot.enable = false;
          generic-extlinux-compatible.enable = true;
        };
      }
    ];
  };

  vmSystem = system: hostSystem:
    genericSystem {
      inherit system;
      extra_modules = [
        {
          nixpkgs.hostPlatform.system = system;
          boot.loader.systemd-boot.enable = false;
          virtualisation.qemu.package = self.nixosConfigurations."${hostSystem}".pkgs.qemu;
        }
      ];
    };
  amd64vmSystem = vmSystem "x86_64-linux";
  armv7lvmSystem = vmSystem "armv7l-linux";
  aarch64vmSystem = vmSystem "aarch64-linux";

  turrisSystem = board: hostname: {
    ${hostname} = nixturris.lib.nixturrisSystem {
      inherit nixpkgs board specialArgs;
      modules = [self.nixosModules.defaultRouters] ++ modules hostname;
    };
  };
  turrisMoxSystem = turrisSystem "mox";
  turrisOmniaSystem = turrisSystem "omnia";
in
  amd64System "albert"
  // amd64System "binky"
  // amd64System "errol"
  // amd64System "ridcully"
  // vpsSystem "lipwig"
  // raspi2System "spt-mpd"
  // raspi3System "adm-mpd"
  // beagleboneSystem "gaspode"
  // turrisMoxSystem "dean"
  // turrisOmniaSystem "spt-omnia"
  // turrisOmniaSystem "spt-omniax"
  // turrisMoxSystem "spt-mox"
  // turrisMoxSystem "spt-mox2"
  // turrisOmniaSystem "adm-omnia"
  // turrisOmniaSystem "adm-omnia2"
