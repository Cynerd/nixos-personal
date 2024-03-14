{
  cynerd = {
    router = {
      enable = true;
      wan = "end2";
      lanIP = "192.168.2.1";
    };
    wifiAP.spt = {
      enable = true;
      ar9287.interface = "wlp3s0";
      qca988x.interface = "wlp2s0";
    };
    monitoring.speedtest = true;
  };

  networking.useDHCP = false;
  systemd.network = {
    networks = {
      "end2" = {
        matchConfig.Name = "end2";
        networkConfig = {
          BindCarrier = "end2";
          DHCP = "yes";
          IPv6AcceptRA = "yes";
          DHCPPrefixDelegation = "yes";
        };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = ":self";
          SubnetId = 0;
          Announce = "no";
        };
        linkConfig.RequiredForOnline = "routable";
      };
      "lan-brlan" = {
        matchConfig.Name = "lan*";
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
