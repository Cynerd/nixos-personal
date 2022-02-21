{ config, lib, pkgs, ... }:

with lib;

let

  cnf = config.cynerd.openvpn;

in {

  options = {
    cynerd.openvpn.enable = mkOption {
      type = types.bool;
      default = false;
      description = "My personal OpenVPN";
    };
  };

  config = mkIf cnf.enable {
    services.openvpn.servers.personal = {
      config = "config /run/secrets/personal.ovpn";
    };
  };

}

