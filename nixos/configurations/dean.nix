{
  lib,
  pkgs,
  ...
}: {
  system.stateVersion = "24.05";
  turris.board = "mox";
  deploy = {
    enable = true;
    configurationLimit = 8;
  };

  cynerd = {
    devmin = true;
    wireguard = true;
    monitoring = {
      speedtest = true;
      drives = false;
    };
  };

  boot.initrd.availableKernelModules = ["dm-mod"];

  hardware.enableAllFirmware = false; # No wifi so we do not need firmwares
  services = {
    journald.settings.Journal = {
      SystemMaxUse = "512M";
    };

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    netdevs."brlab".netdevConfig = {
      Kind = "bridge";
      Name = "brlan";
    };
    networks = {
      "brlan" = {
        matchConfig.Name = "brlan";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
      };
      "lan-brlan" = {
        matchConfig.Name = "lan* end0";
        networkConfig.Bridge = "brlan";
      };
    };
    # TODO investigate why it doesn't work
    wait-online.enable = false;
  };

  environment.systemPackages = with pkgs; [
    #openocd
    tio
    gnupg
  ];

  programs = {
    fuse = {
      enable = true;
      userAllowOther = true;
    };
    nix-ld.enable = true;
  };
  boot.binfmt = {
    emulatedSystems = ["x86_64-linux"];
  };
  environment.sessionVariables = {
    NIX_LD_x86_64_linux = "${pkgs.buildPackages.glibc}/lib/ld-linux-x86-64.so.2";
    NIX_LD_LIBRARY_PATH_x86_64_linux = lib.makeLibraryPath (with pkgs.buildPackages; [
      stdenv.cc.cc
      glibc
      zlib
    ]);
  };
  systemd.tmpfiles.rules = [
    "d /lib64 0755 root root -"
    "L+ /lib64/ld-linux-x86-64.so.2 - - - - ${pkgs.buildPackages.nix-ld}/libexec/nix-ld"
  ];
}
