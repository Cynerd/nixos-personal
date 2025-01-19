{config, ...}: let
  hosts = config.cynerd.hosts.adm;
in {
  turris.board = "omnia";
  deploy = {
    enable = true;
    ssh.host = "adm.cynerd.cz";
  };

  cynerd = {
    router = {
      enable = true;
      wan = "pppoe-wan";
      lanIP = hosts.omnia;
      staticLeases = {
        "70:85:c2:4a:59:f2" = hosts.ridcully;
        "7c:b0:c2:bb:9c:ca" = hosts.albert;
        "4c:d5:77:0d:85:d9" = hosts.binky;
        "b8:27:eb:49:54:5a" = hosts.mpd;
      };
      guestStaticLeases = {
        "f4:a9:97:a4:bd:59" = hosts.printer;
      };
    };
    wifiAP.adm = {
      enable = true;
      ar9287 = {
        interface = "wlp2s0";
        bssids = config.secrets.wifiMacs.adm-omnia.ar9287;
        channel = 7;
      };
      qca988x = {
        interface = "wlp1s0";
        bssids = config.secrets.wifiMacs.adm-omnia.qca988x;
        channel = 44;
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
    networks = {
      "end2" = {
        matchConfig.Name = "end2"; # Ensure that it is managed by systemd-networkd
        networkConfig.IPv6AcceptRA = false;
      };
      "pppoe-wan" = {
        matchConfig.Name = "pppoe-wan";
        networkConfig = {
          BindCarrier = "end2";
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
        matchConfig.Name = "lan4";
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 1;
            PVID = 1;
          }
          {VLAN = 2;}
        ];
      };
      "lan-guest" = {
        matchConfig.Name = "lan[0-3]";
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 2;
            PVID = 2;
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
      defaultroute
      defaultroute6
      #usepeerdns
      maxfail 1
      user O2
      password 02
    '';
  };
  systemd.services."pppd-wan" = {
    after = ["sys-subsystem-net-devices-end2.device"];
    partOf = ["systemd-networkd.service"];
  };
  # TODO limit NSS clamping to just pppoe-wan
  networking.firewall.extraForwardRules = ''
    tcp flags syn tcp option maxseg size set rt mtu comment "Needed for PPPoE to fix IPv4"
    iifname {"home", "wg"} oifname {"home", "wg"} accept
    iifname "home" oifname "guest" accept comment "Allow home to access guest devices"
  '';
}
