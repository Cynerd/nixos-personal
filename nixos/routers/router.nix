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
    networking = {
      useNetworkd = true;
      nftables.enable = true;
      firewall = {
        interfaces = {
          "lan" = {
            allowedUDPPorts = [53 67 68];
            allowedTCPPorts = [53];
          };
          "guest" = {
            allowedUDPPorts = [53 67 68];
            allowedTCPPorts = [53];
          };
        };
        filterForward = true;
        extraForwardRules = ''
          iifname "guest" oifname != "${cnf.wan}" drop comment "prevent guest to access lan"
        '';
      };
      nat = {
        enable = true;
        externalInterface = cnf.wan;
        internalInterfaces = ["lan" "guest"];
      };
    };

    systemd.network = {
      netdevs = {
        "brlan" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "brlan";
          };
          extraConfig = ''
            [Bridge]
            DefaultPVID=none
            VLANFiltering=yes
          '';
        };
        "lan" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "lan";
          };
          vlanConfig.Id = 1;
        };
        "guest" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "guest";
          };
          vlanConfig.Id = 2;
        };
      };
      networks = {
        "brlan" = {
          matchConfig.Name = "brlan";
          networkConfig.VLAN = ["lan" "guest"];
          bridgeVLANs = [
            {bridgeVLANConfig.VLAN = 1;}
            {bridgeVLANConfig.VLAN = 2;}
          ];
        };
        "lan" = {
          matchConfig.Name = "lan";
          networkConfig = {
            Address = "${cnf.lanIP}/${toString cnf.lanPrefix}";
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
            SubnetId = 1;
            Announce = "yes";
          };
        };
        "guest" = {
          matchConfig.Name = "guest";
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

    services.resolved = {
      enable = true;
      dnssec = "true";
      fallbackDns = ["1.1.1.1" "8.8.8.8"];
    };
  };
}
