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
        type = types.string;
        description = "Interface for the router's WAN";
      };
      brlan = mkOption {
        type = types.string;
        default = "brlan";
        description = "LAN interface (commonly some bridge)";
      };
      # TODO IP range and so on
    };
  };

  config = mkIf cnf {
    # TODO firewall NAT
    networking = {
    };

    services.dhcpd4 = {
      enable = true;
      authoritative = true;
      interfaces = ["brlan"];
      extraConfig = ''
      '';
    };

    services.dhcpd6 = {
      enable = true;
      authoritative = true;
      interfaces = ["brlan"];
      extraConfig = ''
      '';
    };

    services.kresd = {
      enable = true;
    };
  };
}
