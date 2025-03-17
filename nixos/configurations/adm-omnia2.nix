{config, ...}: {
  system.stateVersion = "24.05";

  turris.board = "omnia";
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
        interface = "wlp2s0";
        bssids = config.secrets.wifiMacs.adm-omnia2.ar9287;
        channel = 11;
      };
      qca988x = {
        interface = "wlp1s0";
        bssids = config.secrets.wifiMacs.adm-omnia2.qca988x;
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
          EgressUntagged = 1;
          PVID = 1;
        }
        {VLAN = 2;}
      ];
    };
  };
}
