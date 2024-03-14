{config, ...}: {
  cynerd = {
    router = {
      enable = true;
      wan = "pppoe-wan";
      lanIP = config.cynerd.hosts.adm.omnia;
    };
    wifiAP.adm = {
      enable = true;
      ar9287.interface = "wlp3s0";
      qca988x.interface = "wlp2s0";
    };
    openvpn.oldpersonal = false;
    monitoring.speedtest = true;
  };

  networking.useDHCP = false;
  systemd.network = {
    networks = {
      "end2" = {
        matchConfig.Name = "end2";
        #networkConfig = {
        #  DHCP = "ipv6";
        #  IPv6AcceptRA = "yes";
        #  DHCPPrefixDelegation = "yes";
        #};
        #dhcpPrefixDelegationConfig = {
        #  UplinkInterface = ":self";
        #  SubnetId = 0;
        #  Announce = "no";
        #};
        linkConfig.RequiredForOnline = "routable";
      };
      "lan-brlan" = {
        matchConfig.Name = "lan[1-4]";
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
      "lan0-guest" = {
        matchConfig.Name = "lan0";
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              EgressUntagged = 2;
              PVID = 2;
            };
          }
        ];
      };
    };
  };

  services.pppd = {
    enable = true;
    peers."wan".config = ''
      plugin pppoe.so end2
      ifname pppoe-wan
      lcp-echo-interval 1
      lcp-echo-failure 5
      lcp-echo-adaptive
      +ipv6
      defaultroute
      defaultroute6
      usepeerdns
      maxfail 1
      user O2
      password 02
    '';
  };
  systemd.services."pppd-wan".after = ["sys-subsystem-net-devices-end2.device"];
}
