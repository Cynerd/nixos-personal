{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cnf = config.cynerd.switch;
in {
  options = {
    cynerd.switch = {
      enable = mkEnableOption "Enable switch support";
      lanAddress = mkOption {
        type = types.str;
        description = "LAN IP address";
      };
      lanGateway = mkOption {
        type = types.str;
        description = "LAN IP address of the gateway";
      };
    };
  };

  config = mkIf cnf.enable {
    networking.useNetworkd = true;

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
      };
      networks = {
        "brlan" = {
          matchConfig.Name = "brlan";
          bridgeVLANs = [
            {
              bridgeVLANConfig = {
                PVID = 1;
                EgressUntagged = 1;
              };
            }
          ];
          networkConfig = {
            Address = cnf.lanAddress;
            Gateway = cnf.lanGateway;
            DNS = "1.1.1.1";
            IPv6AcceptRA = "yes";
          };
        };
      };
      wait-online.anyInterface = true;
    };
  };
}
