{
  config,
  pkgs,
  ...
}: let
  hosts = config.cynerd.hosts.spt;
in {
  turris.board = "omnia";
  deploy = {
    enable = true;
    ssh.host = "omnia.spt";
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

  environment = {
    etc.crypttab.text = ''
      nas UUID=3472bef9-cbae-48bd-873e-fd4858a0b72f /run/secrets/luks-spt-omnia-nas.key luks
      nassec UUID=016e9e75-bbc8-4b24-8bb7-c800c8f6a500 /run/secrets/luks-spt-omnia-nas.key luks
    '';
    systemPackages = with pkgs; [
      cryptsetup
    ];
  };
  fileSystems = {
    "/data" = {
      device = "/dev/mapper/nas";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@data" "nofail"];
    };
    "/srv" = {
      device = "/dev/mapper/nas";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@srv" "nofail"];
      depends = ["/data"];
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/" "/data"];
  };
  services.udev.packages = [
    (pkgs.writeTextFile rec {
      name = "queue_depth_sata.rules";
      destination = "/etc/udev/rules.d/50-${name}";
      text = ''
        SUBSYSTEMS=="pci", DRIVER=="ahci", ATTR{device}!="0x0612", GOTO="turris_pci_end"
        ACTION=="add|change", SUBSYSTEM=="scsi", ATTR{vendor}=="ATA", ATTR{queue_depth}="1"
        LABEL="turris_pci_end"
      '';
    })
  ];

  users = {
    groups.nas = {};
    users = {
      nas = {
        group = "nas";
        openssh.authorizedKeys.keyFiles = [(config.personal-secrets + "/unencrypted/nas.pub")];
        isNormalUser = true;
        home = "/data/nas";
        homeMode = "770";
      };
      cynerd.extraGroups = ["nas"];
    };
  };
  services.openssh = {
    settings.Macs = ["hmac-sha2-256"]; # Allow sha2-256 for Nexcloud access
    extraConfig = ''
      Match User nas
        X11Forwarding no
        AllowTcpForwarding no
        AllowAgentForwarding no
        ForceCommand internal-sftp -d /data/nas
    '';
  };
  services.fail2ban.enable = true;

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
        };
        dhcpV6Config.PrefixDelegationHint = "::/56";
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
      usepeerdns
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

  services.syncthing = {
    enable = false;
    openDefaultPorts = true;

    overrideDevices = false;
    overrideFolders = false;

    dataDir = "/data"; # TODO this can't be the location
  };
}
