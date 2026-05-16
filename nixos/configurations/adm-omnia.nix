{config, ...}: let
  hosts = config.cynerd.hosts.adm;
in {
  system.stateVersion = "24.05";

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
        "4c:d5:77:0d:85:d9" = hosts.binky;
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

  services = {
    journald.extraConfig = ''
      SystemMaxUse=8G
    '';

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };

    fail2ban = {
      enable = true;
      ignoreIP = ["10.8.0.0/24" "10.8.1.0/24"];
    };
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
  systemd.services = {
    "pppd-wan" = {
      after = ["sys-subsystem-net-devices-end2.device"];
      partOf = ["systemd-networkd.service"];
      serviceConfig = {
        Restart = "always";
        StartLimitBurst = 0;
      };
    };
    "systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  };
  # TODO limit NSS clamping to just pppoe-wan
  networking.firewall.extraForwardRules = ''
    tcp flags syn tcp option maxseg size set rt mtu comment "Needed for PPPoE to fix IPv4"
    iifname "wg" oifname "home" accept
    iifname "home" oifname "guest" accept comment "Allow home to access guest devices"
  '';
}
