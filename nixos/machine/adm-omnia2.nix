{config, ...}: {
  deploy = {
    enable = true;
    ssh.host = "omnia2.adm";
  };

  cynerd = {
    switch = {
      enable = true;
      lanAddress = "${config.cynerd.hosts.adm.omnia2}/24";
      lanGateway = config.cynerd.hosts.adm.omnia;
    };
    wifiAP.adm = {
      enable = true;
      ar9287 = {
        interface = "wlp1s0";
        bssids = ["12:f0:21:23:2b:00" "12:f0:21:23:2b:01" "12:f0:21:23:2b:02"];
        channel = 11;
      };
      qca988x = {
        interface = "wlp2s0";
        bssids = ["12:f0:21:23:2b:03" "12:f0:21:23:2b:04" "12:f0:21:23:2b:05"];
        channel = 36;
      };
    };
  };

  services.journald.extraConfig = ''
    SystemMaxUse=8G
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
      matchConfig.Name = "lan* end2";
      networkConfig.Bridge = "brlan";
      bridgeVLANs = [
        {
          bridgeVLANConfig = {
            EgressUntagged = 1;
            PVID = 1;
          };
        }
        {bridgeVLANConfig.VLAN = 2;}
      ];
    };
  };
}
