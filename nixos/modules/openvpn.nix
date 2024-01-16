{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cnf = config.cynerd.openvpn;
in {
  options = {
    cynerd.openvpn = {
      personal = mkOption {
        type = types.bool;
        default = false;
        description = "My personal OpenVPN";
      };
      oldpersonal = mkOption {
        type = types.bool;
        default = false;
        description = "My personal old OpenVPN";
      };
      elektroline = mkOption {
        type = types.bool;
        default = false;
        description = "Elektroline OpenVPN";
      };
    };
  };

  config = {
    services.openvpn.servers = {
      personal = mkIf cnf.personal {
        config = "config /run/secrets/personal.ovpn";
      };
      oldpersonal = mkIf cnf.oldpersonal {
        config = "config /run/secrets/old.ovpn";
      };
      elektroline = mkIf cnf.elektroline {
        autoStart = false;
        config = "config /run/secrets/elektroline.ovpn";
        updateResolvConf = true;
      };
    };
  };
}
