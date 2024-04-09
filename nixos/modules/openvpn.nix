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
      oldpersonal = mkIf cnf.oldpersonal {
        config = "config /run/secrets/old.ovpn";
      };
      elektroline = mkIf cnf.elektroline {
        config = "config /run/secrets/elektroline.ovpn";
        up = ''
          domain=""
          dns=()
          for optionname in ''${!foreign_option_*} ; do
            read -r p1 p2 p3 <<<"''${!optionname}"
            [[ "$p1" == "dhcp-option" ]] || continue
            case "$p2" in
              DNS)
                dns+=("$p3")
                ;;
              DOMAIN)
                domain="$p3"
                ;;
            esac
          done
          ${pkgs.systemd}/bin/resolvectl dns "$dev" "''${dns[@]}"
          ${pkgs.systemd}/bin/resolvectl domain "$dev" "~$domain"
        '';
      };
    };
  };
}
