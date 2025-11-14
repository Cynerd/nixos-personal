{
  config,
  lib,
  pkgs,
  modulesPath,
  extendModules,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkDefault;
  variant = extendModules {
    modules = [
      {
        boot.postBootCommands = ''
          # On the first boot do some maintenance tasks
          if [ -f /nix-path-registration ]; then
            set -euo pipefail

            # Register the contents of the initial Nix store
            ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

            # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
            touch /etc/NIXOS
            ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

            # Prevents this from running on later boots.
            rm -f /nix-path-registration
          fi
        '';
        # We do not have generations in the initial image
        boot.loader.generic-extlinux-compatible.configurationLimit = 0;
      }
    ];
  };
  inherit (variant.config.system.build) toplevel;
in {
  options.cynerd.openwrtone = mkEnableOption "Configuration for OpenWrt One";

  config = mkIf config.cynerd.openwrtone {
    nixpkgs = {
      hostPlatform = {
        config = "aarch64-unknown-linux-gnu";
        system = "aarch64-linux";
      };
      buildPlatform = {
        config = "x86_64-unknown-linux-gnu";
        system = "x86_64-linux";
      };
    };

    # We do not need Grub as U-Boot supports boot using extlinux like file
    boot = {
      loader = {
        grub.enable = mkDefault false;
        systemd-boot.enable = mkDefault false;
        generic-extlinux-compatible.enable = mkDefault true;
      };

      # Use OpenWrt One specific kernel. It fixes SError with patch.
      kernelPackages = mkDefault (pkgs.linuxPackagesFor pkgs.linuxOpenWrtOne);
      kernelParams = [
        "fw_devlink=permissive"
        "clk_ignore_unused"
        "pcie_aspm=off"
      ];

      initrd = {
        kernelModules = ["pcie-mediatek-gen3" "nvme"];
        # This includes modules to support common PC manufacturers but is not
        # something required on embedded device.
        includeDefaultModules = false;
        supportedFilesystems = ["btrfs"];
      };
      supportedFilesystems = ["btrfs"];
    };
    hardware.deviceTree.name = mkDefault "mediatek/mt7981b-openwrt-one.dtb";

    # Cover nix memory consumption peaks by compressing the RAM
    zramSwap = mkDefault {
      enable = true;
      memoryPercent = 80;
    };

    fileSystems = {
      "/boot" = mkDefault {
        device = "/dev/nvme0n1p1";
        fsType = "vfat";
      };
      "/" = mkDefault {
        device = "/dev/nvme0n1p2";
        fsType = "btrfs";
      };
    };

    environment.systemPackages = with pkgs; [
      iw
    ];

    # No need for installer tools in standard system
    system.disableInstallerTools = true;
    # No need for NixOS documentation in headless system
    documentation.nixos.enable = mkDefault false;

    system.build.tarball = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
      extraCommands = pkgs.buildPackages.writeShellScript "tarball-extra-commands" ''
        ${variant.config.boot.loader.generic-extlinux-compatible.populateCmd} \
          -c ${toplevel} -d ./boot
      '';
      contents = [];

      storeContents =
        map (x: {
          object = x;
          symlink = "none";
        }) [
          toplevel
          pkgs.stdenv
        ];
    };
  };
}
