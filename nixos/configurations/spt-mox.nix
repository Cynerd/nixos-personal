{config, ...}: {
  turris.board = "mox";
  deploy = {
    enable = true;
    ssh.host = "mox.spt";
  };

  cynerd = {
    home-assistant = true;
    monitoring.drives = false;
    switch = {
      enable = true;
      lanAddress = "${config.cynerd.hosts.spt.mox}/24";
      lanGateway = config.cynerd.hosts.spt.omnia;
    };
    wifiAP.spt = {
      enable = true;
      qca988x = {
        interface = "wlp1s0";
        bssids = ["04:f0:21:24:24:d2" "08:f0:21:24:24:d2"];
        channel = 7;
      };
    };
  };

  services.journald.extraConfig = ''
    SystemMaxUse=512M
  '';

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network.networks = {
    "lan-brlan" = {
      matchConfig.Name = "lan* end0";
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
