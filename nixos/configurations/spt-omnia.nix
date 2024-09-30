{config, ...}: let
  hosts = config.cynerd.hosts.spt;
in {
  turris.board = "omnia";
  deploy = {
    enable = true;
    ssh.host = "spt.cynerd.cz";
  };

  cynerd = {
    router = {
      enable = true;
      wan = "pppoe-wan";
      lanIP = hosts.omnia;
      staticLeases = {
        "a8:a1:59:10:32:c4" = hosts.errol;
        "7c:b0:c2:bb:9c:ca" = hosts.albert;
        "4c:d5:77:0d:85:d9" = hosts.binky;
        "b8:27:eb:57:a2:31" = hosts.mpd;
        "74:bf:c0:42:82:19" = hosts.printer;
      };
    };
    wifiAP.spt = {
      enable = true;
      ar9287 = {
        interface = "wlp1s0";
        bssids = ["04:f0:21:24:21:93" "08:f0:21:24:21:93"];
        channel = 11;
      };
      qca988x = {
        interface = "wlp3s0";
        bssids = ["04:f0:21:23:16:64" "08:f0:21:23:16:64"];
        channel = 36;
      };
    };
    wireguard = true;
    monitoring.speedtest = true;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=8G
  '';

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
  };

  services.fail2ban = {
    enable = true;
    ignoreIP = ["10.8.1.0/24" "10.8.2.0/24"];
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
        networkConfig.BindCarrier = "end2";
      };
      "pppoe-wan" = {
        matchConfig.Name = "pppoe-wan";
        networkConfig = {
          BindCarrier = "end2.848";
          DHCP = "ipv6";
          IPv6AcceptRA = "no";
          DHCPPrefixDelegation = "yes";
          DNS = "1.1.1.1";
        };
        dhcpV6Config = {
          PrefixDelegationHint = "::/56";
          UseDNS = "no";
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
            EgressUntagged = 1;
            PVID = 1;
          }
          {VLAN = 2;}
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
      defaultroute
      defaultroute6
      #usepeerdns
      maxfail 1
      user metronet
      password metronet
    '';
  };
  systemd.services."pppd-wan".after = ["sys-subsystem-net-devices-end2.848.device"];
  # TODO limit NSS clamping to just pppoe-wan
  networking.firewall.extraForwardRules = ''
    tcp flags syn tcp option maxseg size set rt mtu comment "Needed for PPPoE to fix IPv4"
    iifname {"home", "personalvpn", "wg"} oifname {"home", "personalvpn", "wg"} accept
  '';
}
