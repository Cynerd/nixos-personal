{
  config,
  lib,
  ...
}:
with lib; let
  cnf = config.cynerd.router;
in {
  options = {
    cynerd.router = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable router support";
      };
      wan = mkOption {
        type = types.str;
        description = "Interface for the router's WAN";
      };
      lanIP = mkOption {
        type = types.str;
        description = "LAN IP address";
      };
      dynIPStart = mkOption {
        type = types.ints.between 0 256;
        default = 100;
        description = "Offset for the dynamic IPv4 addresses";
      };
      dynIPCount = mkOption {
        type = types.ints.between 0 256;
        default = 100;
        description = "Number of dynamically assigned IPv4 addresses";
      };
      lanPrefix = mkOption {
        type = types.ints.between 0 32;
        default = 24;
        description = "LAN IP network prefix length";
      };
    };
  };

  config = mkIf cnf.enable {
    systemd.network = {
      netdevs = {
        "brlan".netdevConfig = {
          Kind = "bridge";
          Name = "brlan";
        };
        "brguest".netdevConfig = {
          Kind = "bridge";
          Name = "brguest";
        };
      };
      networks = {
        "${cnf.wan}" = {
          matchConfig.Name = cnf.wan;
          networkConfig = {
            DHCP = "yes";
            DHCPPrefixDelegation = "yes";
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = ":self";
            SubnetId = 0;
            Announce = "no";
          };
          linkConfig.RequiredForOnline = "routable";
        };
        "brlan" = {
          matchConfig.Name = "brlan";
          networkConfig = {
            Address = "${cnf.lanIP}/${toString cnf.lanPrefix}";
            IPForward = "yes";
            DHCPServer = "yes";
            DHCPPrefixDelegation = "yes";
            IPv6SendRA = "yes";
            IPv6AcceptRA = "no";
            VLAN = ["brlan.brguest"];
          };
          dhcpServerConfig = {
            UplinkInterface = cnf.wan;
            PoolOffset = cnf.dynIPStart;
            PoolSize = cnf.dynIPCount;
            EmitDNS = "yes";
            DNS = "1.1.1.1";
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = cnf.wan;
            SubnetId = 1;
            Announce = "yes";
          };
        };
        "brguest" = {
          matchConfig.Name = "brguest";
          networkConfig = {
            Address = "192.168.1.1/24";
            IPForward = "yes";
            DHCPServer = "yes";
            DHCPPrefixDelegation = "yes";
            IPv6SendRA = "yes";
            IPv6AcceptRA = "no";
          };
          dhcpServerConfig = {
            UplinkInterface = cnf.wan;
            PoolOffset = cnf.dynIPStart;
            PoolSize = cnf.dynIPCount;
            EmitDNS = "yes";
            DNS = "1.1.1.1";
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = cnf.wan;
            SubnetId = 2;
            Announce = "yes";
          };
        };
      };
      wait-online.anyInterface = true;
    };

    networking = {
      nftables.enable = true;
      firewall = {
        interfaces = {
          "brlan" = {
            allowedUDPPorts = [53 67 68];
            allowedTCPPorts = [53];
          };
          "brguest" = {
            allowedUDPPorts = [53 67 68];
            allowedTCPPorts = [53];
          };
        };
        filterForward = true;
        extraForwardRules = ''
          iifname "brguest" oifname != "${cnf.wan}" drop comment "prevent guest to access lan"
        '';
      };
      nat = {
        enable = true;
        externalInterface = cnf.wan;
        internalInterfaces = ["brlan" "brguest"];
      };
    };

    services.resolved = {
      enable = true;
      dnssec = "true";
      fallbackDns = ["1.1.1.1" "8.8.8.8"];
    };

    #networking = {
    #  interfaces = {
    #    brlan.ipv4.addresses = [
    #      {
    #        address = cnf.lanIP;
    #        prefixLength = cnf.lanPrefix;
    #      }
    #    ];
    #    brguest.ipv4.addresses = [
    #      {
    #        address = "192.168.1.1";
    #        prefixLength = 24;
    #      }
    #    ];
    #  };
    #  vlans = {
    #    "brlan.guest" = {
    #      interface = "brlan";
    #      id = 100;
    #    };
    #  };
    #  bridges = {
    #    brlan.interfaces = [];
    #    brguest.interfaces = ["brlan.guest"];
    #  };
    #  nat = {
    #    enable = true;
    #    externalInterface = cnf.wan;
    #    internalInterfaces = ["brlan" "brguest"];
    #  };
    #  dhcpcd = {
    #    allowInterfaces = [cnf.wan];
    #    extraConfig = ''
    #      duid
    #      noipv6rs
    #      waitip 6

    #      interface ${cnf.wan}
    #      ipv6rs
    #      iaid 1

    #      ia_pd 1 brlan
    #      #ia_pd 1/::/64 LAN/0/64
    #toString     '';
    #  };
    #nameservers = ["1.1.1.1" "8.8.8.8"];
    #};

    #services = {
    #  kea = {
    #    dhcp4 = {
    #      enable = true;
    #      settings = {
    #        lease-database = {
    #          name = "/var/lib/kea/dhcp4.leases";
    #          persist = true;
    #          type = "memfile";
    #        };
    #        valid-lifetime = 4000;
    #        renew-timer = 1000;
    #        rebind-timer = 2000;
    #        interfaces-config = {
    #          interfaces = ["brlan" "brguest"];
    #          service-sockets-max-retries = -1;
    #        };
    #        option-data = [
    #          {
    #            name = "domain-name-servers";
    #            data = "1.1.1.1, 8.8.8.8";
    #          }
    #        ];
    #        subnet4 = [
    #          {
    #            interface = "brlan";
    #            subnet = "${ipv4.prefix2ip cnf.lanIP cnf.lanPrefix}/${toString cnf.lanPrefix}";
    #            pools = let
    #              ip_start = ipv4.ipAdd cnf.lanIP cnf.lanPrefix cnf.dynIPStart;
    #              ip_end = ipv4.ipAdd cnf.lanIP cnf.lanPrefix (cnf.dynIPStart + cnf.dynIPCount);
    #            in [{pool = "${ip_start} - ${ip_end}";}];
    #            option-data = [
    #              {
    #                name = "routers";
    #                data = cnf.lanIP;
    #              }
    #            ];
    #            reservations = [
    #              {
    #                duid = "e4:6f:13:f3:d5:be";
    #                ip-address = ipv4.ipAdd cnf.lanIP cnf.lanPrefix 60;
    #              }
    #            ];
    #          }
    #          {
    #            interface = "brguest";
    #            subnet = "192.168.1.0/24";
    #            pools = [{pool = "192.168.1.50 - 192.168.1.254";}];
    #            "option-data" = [
    #              {
    #                name = "routers";
    #                data = "192.168.1.1";
    #              }
    #            ];
    #          }
    #        ];
    #      };
    #    };
    #  };
    #  radvd = {
    #    enable = true;
    #    config = ''
    #      interface brlan {
    #        AdvSendAdvert on;
    #        MinRtrAdvInterval 3;
    #        MaxRtrAdvInterval 10;
    #        prefix ::/64 {
    #          AdvOnLink on;
    #          AdvAutonomous on;
    #          AdvRouterAddr on;
    #        };
    #        RDNSS 2001:4860:4860::8888 2001:4860:4860::8844 {
    #        };
    #      };
    #    '';
    #  };
    #  kresd = {enable = false;};
    #};
    #systemd.services.kea-dhcp4-server.after = [
    #  "sys-subsystem-net-devices-brlan.device"
    #  "sys-subsystem-net-devices-brguest.device"
    #];
  };
}
