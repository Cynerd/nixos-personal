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
        lanAddress = "${config.cynerd.hosts.spt.mox2}/24";
        lanGateway = config.cynerd.hosts.spt.omnia;
      };
      wifiAP.spt = {
        enable = true;
        qca988x = {
          interface = "wls1";
          bssids = ["04:f0:21:45:d3:47" "08:f0:21:45:d3:47"];
          channel = 1;
        };
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
