{pkgs, ...}: {
  system.stateVersion = "24.05";
  nixpkgs.hostPlatform.system = "x86_64-linux";
  deploy.enable = true;

  cynerd = {
    desktop.enable = true;
    develop = true;
    gaming = true;
    openvpn = {
      elektroline = true;
    };
    borgjobs = {
      hetzner-s3.paths = "/back/hetzner-s3-sync";
    };
  };

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd"];

  hardware.cpu.amd.updateMicrocode = true;
  services.hardware.openrgb.motherboard = "amd";

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  cynerd.autounlock = {
    "encroot" = "/dev/disk/by-uuid/bc7d2ba4-6e04-4c49-b40c-3aecd1a86c71";
    "enchdd" = "/dev/disk/by-uuid/7fee3cda-efa0-47cd-8832-fdead9a7e6db";
    "encback" = "/dev/disk/by-uuid/b426cbe7-fba2-473b-90f9-9ebe3e34b76e";
  };
  fileSystems = {
    "/" = {
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
      device = "/dev/disk/by-uuid/6DAD-3819";
      fsType = "vfat";
    };

    "/home2" = {
      device = "/dev/mapper/enchdd";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@home"];
    };
    "/back" = {
      device = "/dev/mapper/encback";
      fsType = "btrfs";
      options = ["compress=lzo"];
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/" "/home2"];
  };

  networking = {
    useNetworkd = true;
    useDHCP = true;
  };
  systemd.network = {
    wait-online.enable = false;
  };

  environment.systemPackages = [
    pkgs.nvtopPackages.amd
    #sbctl
  ];

  # Force nix to use less jobs
  nix.settings.max-jobs = 4;

  ##############################################################################
  services = {
    syncthing = {
      enable = true;
      dataDir = "/home/cynerd";
    };

    octoprint = {
      enable = true;
      openFirewall = true;
    };

    mjpg-streamer = {
      enable = true;
      inputPlugin = "input_uvc.so -d /dev/video2 -r 1920x1080 -f 30";
      outputPlugin = "output_http.so -p 5001 -w @www@";
    };
  };
  networking.firewall.allowedTCPPorts = [5001];

  # Service to synchronize local copy of Hetzner S3
  systemd = {
    services."hetzner-sync" = {
      script = ''
        /run/current-system/sw/bin/rclone --config /run/secrets/rclone-hetzner.conf \
          sync hetzner: /back/hetzner-s3-sync
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
    timers."hetzner-sync" = {
      wantedBy = ["timers.target"];
      timerConfig.Unit = "hetzner-sync.service";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = false;
      };
    };
  };
}
