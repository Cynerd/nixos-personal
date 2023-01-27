{
  config,
  lib,
  pkgs,
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
    networking = {
      interfaces = {
        brlan.ipv4.addresses = [
          {
            address = cnf.lanIP;
            prefixLength = cnf.lanPrefix;
          }
        ];
        brguest.ipv4.addresses = [
          {
            address = "192.168.1.1";
            prefixLength = 24;
          }
        ];
      };
      vlans = {
        "brlan.guest" = {
          interface = "brlan";
          id = 100;
        };
      };
      bridges = {
        brlan.interfaces = [];
        brguest.interfaces = ["brlan.guest"];
      };
      nat = {
        enable = true;
        externalInterface = cnf.wan;
        internalInterfaces = ["brlan" "brguest"];
      };
      dhcpcd.allowInterfaces = [cnf.wan];
      nameservers = ["1.1.1.1" "8.8.8.8"];
    };

    services.kea = {
      dhcp4 = {
        enable = true;
        settings = {
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          valid-lifetime = 4000;
          renew-timer = 1000;
          rebind-timer = 2000;
          interfaces-config = {
            interfaces = ["brlan" "brguest"];
            service-sockets-max-retries = -1;
          };
          option-data = [
            {
              name = "domain-name-servers";
              data = "1.1.1.1, 8.8.8.8";
            }
          ];
          subnet4 = [
            {
              interface = "brlan";
              subnet = "${ipv4.prefix2ip cnf.lanIP cnf.lanPrefix}/${toString cnf.lanPrefix}";
              pools = let
                ip_start = ipv4.ipAdd cnf.lanIP cnf.lanPrefix cnf.dynIPStart;
                ip_end = ipv4.ipAdd cnf.lanIP cnf.lanPrefix (cnf.dynIPStart + cnf.dynIPCount);
              in [{pool = "${ip_start} - ${ip_end}";}];
              option-data = [
                {
                  name = "routers";
                  data = ipv4.prefix2netmask cnf.lanPrefix;
                }
              ];
              reservations = [
                {
                  duid = "e4:6f:13:f3:d5:be";
                  ip-address = ipv4.ipAdd cnf.lanIP cnf.lanPrefix 60;
                }
              ];
            }
            {
              interface = "brguest";
              subnet = "192.168.1.0/24";
              pools = [{pool = "192.168.1.50 - 192.168.1.254";}];
              "option-data" = [
                {
                  name = "routers";
                  data = "192.168.1.1";
                }
              ];
            }
          ];
        };
      };
      # TODO dhcp6
    };
    systemd.services.kea-dhcp4-server.after = [
      "sys-subsystem-net-devices-brlan.device"
      "sys-subsystem-net-devices-brguest.device"
    ];

    services.kresd = {
      enable = false;
    };

    networking.nftables.enable = true;
    networking.firewall = {
      filterForward = true;
      extraForwardRules = ''
        iifname "brguest" oifname != "${cnf.wan}" drop comment "prevent guest to access lan"
      '';
    };
  };
}
