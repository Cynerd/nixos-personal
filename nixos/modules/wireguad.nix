{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mapAttrsToList optional optionals optionalAttrs filterAttrs;
  inherit (config.networking) hostName;
  endpoints = {
    "lipwig" = "cynerd.cz";
    "spt-omnia" = "spt.cynerd.cz";
    "adm-omnia" = "adm.cynerd.cz";
  };
  is_endpoint = endpoints ? "${hostName}";
in {
  options = {
    cynerd.wireguard = mkEnableOption "Enable Wireguard";
  };

  config = mkIf config.cynerd.wireguard {
    environment.systemPackages = [pkgs.wireguard-tools];
    systemd.network = {
      netdevs."wg" = {
        netdevConfig = {
          Name = "wg";
          Kind = "wireguard";
          Description = "Personal Wireguard tunnel";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          ListenPort = 51820;
          PrivateKeyFile = "/run/secrets/wg.key";
        };
        wireguardPeers =
          [
            {
              wireguardPeerConfig =
                {
                  Endpoint = "${endpoints.lipwig}:51820";
                  AllowedIPs = ["0.0.0.0/0"];
                  PublicKey = config.secrets.wireguardPubs.lipwig;
                }
                // (optionalAttrs (!is_endpoint) {PersistentKeepalive = 25;});
            }
            {
              wireguardPeerConfig =
                {
                  Endpoint = "${endpoints.spt-omnia}:51820";
                  AllowedIPs = [
                    "${config.cynerd.hosts.wg.spt-omnia}/32"
                    "10.8.2.0/24"
                  ];
                  PublicKey = config.secrets.wireguardPubs.spt-omnia;
                }
                // (optionalAttrs (!is_endpoint) {PersistentKeepalive = 25;});
            }
            #{
            #  wireguardPeerConfig =
            #    {
            #      Endpoint = "${endpoints.adm-omnia}:51820";
            #      AllowedIPs = [
            #        "${config.cynerd.hosts.wg.adm-omnia}/32"
            #        "10.8.3.0/24"
            #      ];
            #      PublicKey = config.secrets.wireguardPubs.adm-omnia;
            #    }
            #    // (optionalAttrs (!is_endpoint) {PersistentKeepalive = 25;});
            #}
          ]
          ++ (optionals is_endpoint (mapAttrsToList (n: v: {
            wireguardPeerConfig = {
              AllowedIPs = "${config.cynerd.hosts.wg."${n}"}/32";
              PublicKey = v;
            };
          }) (filterAttrs (n: _: ! endpoints ? "${n}") config.secrets.wireguardPubs)));
      };
      networks."wg" = {
        matchConfig.Name = "wg";
        networkConfig = {
          Address = "${config.cynerd.hosts.wg."${hostName}"}/24";
          IPForward = is_endpoint;
        };
        routes =
          (optional (hostName != "spt-omnia") {
            routeConfig = {
              Gateway = config.cynerd.hosts.wg.spt-omnia;
              Destination = "10.8.2.0/24";
            };
          })
          ++ (optional (hostName != "adm-omnia" && hostName != "lipwig") {
            routeConfig = {
              Gateway = config.cynerd.hosts.wg.adm-omnia;
              Destination = "10.8.3.0/24";
            };
          });
      };
    };
    networking.firewall.allowedUDPPorts = [51820];
  };
}
