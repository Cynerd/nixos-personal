{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    cynerd = {
      switch = {
        enable = true;
        lanAddress = "${config.cynerd.hosts.adm.omnia2}/24";
        lanGateway = config.cynerd.hosts.adm.omnia;
      };
      wifiAP.adm = {
        enable = true;
        ar9287.interface = "wlp2s0";
        qca988x.interface = "wlp1s0";
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
    systemd.network.networks = {
      "lan-brlan" = {
        matchConfig.Name = "lan* eth0";
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
  };
}
