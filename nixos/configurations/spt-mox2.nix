{config, ...}: {
  system.stateVersion = "24.05";
  turris.board = "mox";
  deploy = {
    enable = true;
    ssh.host = "mox2.spt";
  };

  cynerd = {
    monitoring.drives = false;
    switch = {
      enable = true;
      lanAddress = "${config.cynerd.hosts.spt.mox2}/24";
      lanGateway = config.cynerd.hosts.spt.omnia;
    };
    wifiAP.spt = {
      enable = true;
      qca988x = {
        interface = "wlp1s0";
        bssids = config.secrets.wifiMacs.spt-mox2.qca988x;
        channel = 1;
      };
    };
  };

  boot.initrd.availableKernelModules = ["dm-mod"];

  services = {
    journald.extraConfig = ''
      SystemMaxUse=512M
    '';

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network.networks = {
    "lan-brlan" = {
      matchConfig.Name = "end0";
      networkConfig.Bridge = "brlan";
      bridgeVLANs = [
        {
          EgressUntagged = 1;
          PVID = 1;
        }
        {VLAN = 2;}
      ];
    };
  };
}
