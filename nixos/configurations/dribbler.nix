{pkgs, ...}: {
  system.stateVersion = "25.11";
  nixpkgs.hostPlatform.system = "x86_64-linux";
  deploy = {
    enable = true;
    default = false;
    ssh.host = "dribbler";
  };

  cynerd = {
    wifiClient = true;
  };

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
  };

  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.luks.devices = {
    "encroot".device = "/dev/disk/by-uuid/b317feb5-d68d-4ec3-a24f-0307c116cac8";
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@"];
    };
    "/nix" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@nix"];
    };
    "/home" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@home"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8F7D-A154";
      fsType = "vfat";
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    networks = {
      "dhcp" = {
        matchConfig.Name = "enp2s0f0";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
      };
      "dhcp-wlan" = {
        matchConfig.Name = "wlp3s0";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
        routes = [{Metric = 1088;}];
        linkConfig.RequiredForOnline = "routable";
      };
    };
    wait-online.enable = false;
  };

  # Kodi
  nixpkgs.config.kodi.enableAdvancedLauncher = true;
  users.extraUsers.kodi.isNormalUser = true;
  services.cage = {
    user = "kodi";
    program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    enable = true;
  };
  networking.firewall = {
    allowedTCPPorts = [8080];
    allowedUDPPorts = [8080];
  };
}
