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

    services.dhcpd4 = {
      enable = true;
      authoritative = true;
      interfaces = ["brlan" "brguest"];
      extraConfig = ''
        option domain-name-servers 1.1.1.1, 8.8.8.8;
        subnet ${ipv4.prefix2ip cnf.lanIP cnf.lanPrefix} netmask ${ipv4.prefix2netmask cnf.lanPrefix} {
            range ${
          ipv4.ipAdd cnf.lanIP cnf.lanPrefix cnf.dynIPStart
        } ${
          ipv4.ipAdd cnf.lanIP cnf.lanPrefix (cnf.dynIPStart + cnf.dynIPCount)
        };
            option routers ${cnf.lanIP};
            option subnet-mask ${ipv4.prefix2netmask cnf.lanPrefix};
            option broadcast-address ${ipv4.prefix2broadcast cnf.lanIP cnf.lanPrefix};
        }
        subnet 192.168.1.0 netmask 255.255.255.0 {
          range 192.168.1.50 192.168.1.254;
          option routers 192.168.1.1;
          option subnet-mask 255.255.255.0;
          option broadcast-address 192.168.1.255;
        }
      '';
    };

    services.dhcpd6 = {
      # TODO
      enable = false;
      authoritative = true;
      interfaces = ["brlan"];
      extraConfig = ''
      '';
    };

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
