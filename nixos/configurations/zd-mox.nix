{
  config,
  pkgs,
  ...
}: let
  hosts = config.cynerd.hosts.zd;
in {
  system.stateVersion = "25.05";
  turris.board = "mox";
  deploy = {
    enable = true;
    ssh.host = "zd.cynerd.cz";
  };

  cynerd = {
    router = {
      enable = true;
      wan = "pppoe-wan";
      lanIP = hosts.mox;
      staticLeases = {
        "70:85:c2:4a:59:f2" = hosts.ridcully;
        "f8:dc:7a:79:00:e6" = hosts.tc;
        "4c:d5:77:0d:85:d9" = hosts.binky;
      };
    };
    wireguard = true;
    monitoring.speedtest = true;
  };

  boot.initrd.availableKernelModules = ["dm-mod"];

  services = {
    journald.extraConfig = ''
      SystemMaxUse=512M
    '';

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };

    fail2ban = {
      enable = true;
      ignoreIP = ["10.8.0.0/24" "10.8.1.0/24" "10.8.2.0/24"];
    };
  };

  networking.useDHCP = false;
  systemd.network = {
    netdevs = {
      "end0.848" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "end0.848";
        };
        vlanConfig.Id = 848;
      };
    };
    networks = {
      "end0" = {
        matchConfig.Name = "end0";
        networkConfig.VLAN = ["end0.848"];
      };
      "end0.848" = {
        matchConfig.Name = "end0.848";
        networkConfig.BindCarrier = "end0";
      };
      "pppoe-wan" = {
        matchConfig.Name = "pppoe-wan";
        networkConfig = {
          BindCarrier = "end0.848";
          DHCP = "ipv6";
          IPv6AcceptRA = "no";
          DHCPPrefixDelegation = "yes";
          #DNS = ["84.19.64.3" "84.19.64.4" "1.1.1.1"];
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
      plugin pppoe.so end0.848
      ifname pppoe-wan
      lcp-echo-interval 1
      lcp-echo-failure 5
      lcp-echo-adaptive
      defaultroute
      defaultroute6
      maxfail 1
      # user and password added in secrets
    '';
  };
  systemd.services = {
    "pppd-wan" = {
      requires = ["sys-subsystem-net-devices-end0.848.device"];
      partOf = ["systemd-networkd.service"];
    };
    "systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  };
  # TODO limit NSS clamping to just pppoe-wan
  networking.firewall.extraForwardRules = ''
    tcp flags syn tcp option maxseg size set rt mtu comment "Needed for PPPoE to fix IPv4"
    iifname {"home", "wg"} oifname {"home", "wg"} accept
  '';

  services.nginx = {
    enable = true;
    virtualHosts = {
      "zd.cynerd.cz" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${hosts.one0}:8123";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "cynerd+acme@email.cz";
    certs."zd.cynerd.cz" = {};
  };
  networking.firewall.allowedTCPPorts = [80 443];

  environment.systemPackages = with pkgs; [
    nmap
    tcpdump
  ];
}
