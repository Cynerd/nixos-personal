{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    cynerd = {
      router = {
        enable = true;
        wan = "pppoe-wan";
        lanIP = config.cynerd.hosts.spt.omnia;
      };
      wifiAP.spt = {
        enable = true;
        ar9287 = {
          interface = "wlp3s0";
          bssids = ["04:f0:21:23:16:64" "08:f0:21:23:16:64"];
          channel = 13;
        };
        qca988x = {
          interface = "wlp2s0";
          bssids = ["04:f0:21:24:21:93" "08:f0:21:24:21:93"];
          channel = 36;
        };
      };
      openvpn.oldpersonal = true;
      monitoring.speedtest = true;
    };

    networking.useDHCP = false;
    systemd.network = {
      netdevs = {
        "end2.848" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "end2.848";
          };
          vlanConfig.Id = 848;
        };
      };
      networks = {
        "end2" = {
          matchConfig.Name = "end2";
          networkConfig.VLAN = ["end2.848"];
        };
        "end2.848" = {
          matchConfig.Name = "end2.848";
          networkConfig = {
            BindCarrier = "end2";
            #DHCP = "ipv6";
            #IPv6AcceptRA = "yes";
            #DHCPPrefixDelegation = "yes";
          };
          #dhcpPrefixDelegationConfig = {
          #  UplinkInterface = ":self";
          #  SubnetId = 0;
          #  Announce = "no";
          #};
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

    services.pppd = {
      enable = true;
      peers."wan".config = ''
        plugin pppoe.so end2.848
        ifname pppoe-wan
        lcp-echo-interval 1
        lcp-echo-failure 5
        lcp-echo-adaptive
        +ipv6
        defaultroute
        defaultroute6
        usepeerdns
        maxfail 1
        user metronet
        password metronet
      '';
    };
    systemd.services."pppd-wan".after = ["sys-subsystem-net-devices-end2.848.device"];

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;

      overrideDevices = false;
      overrideFolders = false;

      dataDir = "/data";
    };
  };
}
