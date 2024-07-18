{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mkIf mapAttrsToList;
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
      staticLeases = mkOption {
        type = with types; attrsOf str;
        default = {};
        example = ''
          {"xx:xx:xx:xx:xx:xx" = "10.8.1.30";}
        '';
        description = "Mapping of MAC address to IP address";
      };
      guestStaticLeases = mkOption {
        type = with types; attrsOf str;
        default = {};
        example = ''
          {"xx:xx:xx:xx:xx:xx" = "10.8.1.30";}
        '';
        description = "Mapping of MAC address to IP address";
      };
    };
  };

  config = mkIf cnf.enable {
    networking = {
      useNetworkd = true;
      firewall = {
        logRefusedConnections = false;
        interfaces = {
          "home" = {allowedUDPPorts = [53 67 68];};
          "guest" = {allowedUDPPorts = [53 67 68];};
        };
        filterForward = true;
      };
      nat = {
        enable = true;
        externalInterface = cnf.wan;
        internalInterfaces = ["home" "guest"];
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
        "home" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "home";
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
          networkConfig.VLAN = ["home" "guest"];
          bridgeVLANs = [
            {VLAN = 1;}
            {VLAN = 2;}
          ];
        };
        "home" = {
          matchConfig.Name = "home";
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
            DNS = "${cnf.lanIP}";
          };
          dhcpServerStaticLeases =
            mapAttrsToList (n: v: {
              MACAddress = n;
              Address = v;
            })
            cnf.staticLeases;
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
            DNS = "192.168.1.1";
          };
          dhcpServerStaticLeases =
            mapAttrsToList (n: v: {
              MACAddress = n;
              Address = v;
            })
            cnf.guestStaticLeases;
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
      extraConfig = ''
        DNSStubListenerExtra=${cnf.lanIP}
        DNSStubListenerExtra=192.168.1.1
      '';
    };
  };
}
