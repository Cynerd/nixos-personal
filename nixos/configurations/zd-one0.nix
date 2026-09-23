{config, ...}: {
  system.stateVersion = "25.11";
  deploy = {
    enable = true;
    #ssh.host = "zd-one0";
    ssh.host = "one0nix";
  };

  cynerd = {
    openwrtone = true;
    switch = {
      enable = true;
      lanAddress = "${config.cynerd.hosts.zd.one0nix}/24";
      lanGateway = config.cynerd.hosts.zd.mox;
    };
    wifiAP.zd = {
      enable = false;
      wlan0 = {
        bssids = [
          "20:05:b7:00:4c:02"
          "20:05:b7:04:4c:02"
          "20:05:b7:08:4c:02"
        ];
        channel = 7;
      };
    };
  };

  boot.initrd.availableKernelModules = ["dm-mod"];
  boot.consoleLogLevel = 7;

  services = {
    journald.settings.Journal = {
      SystemMaxUse = "32G";
    };

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };

    fail2ban = {
      enable = true;
      ignoreIP = ["10.8.0.0/24" "10.8.1.0/24" "10.8.2.0/24"];
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network.networks = {
    "lan-brlan" = {
      matchConfig.Name = "end*";
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
