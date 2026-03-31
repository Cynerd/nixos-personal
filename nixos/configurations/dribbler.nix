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
    kernelParams = ["video=eDP-1:d"]; # Disable internal display for kodi to use HDMI
  };

  hardware.cpu.intel.updateMicrocode = true;

  cynerd.autounlock = {
    "encroot" = "/dev/disk/by-uuid/f791f524-0552-487b-9bf9-5c20ca78651b";
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/7143-1EE7";
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
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
      };
      "dhcp-wlan" = {
        matchConfig.Name = "wlp2s0";
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
  environment.systemPackages = with pkgs; [
    kodi-gbm
  ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
      ];
    };
    bluetooth.enable = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  #nixpkgs.config.kodi.enableAdvancedLauncher = true;
  users.extraUsers.kodi = {
    isNormalUser = true;
    extraGroups = ["audio" "video" "input"];
  };
  systemd.services.kodi = {
    description = "Kodi standalone (GBM)";
    wantedBy = ["multi-user.target"];
    conflicts = ["getty@tty1.service"];
    serviceConfig = {
      User = "kodi";
      TTYPath = "/dev/tty1";
      ExecStart = "${pkgs.kodi-gbm}/bin/kodi-standalone";
      Restart = "on-abort";
      StandardInput = "tty";
      StandardOutput = "journal";
    };
  };
  networking.firewall = {
    allowedTCPPorts = [8080];
    allowedUDPPorts = [8080];
  };
}
