{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) any all mkEnableOption mkIf mapAttrsToList optional optionals optionalAttrs filterAttrs;
  inherit (config.networking) hostName;
  endpoints = ["lipwig" "spt-omnia" "adm-omnia" "dean"];
  is_endpoint = any (v: v == hostName) endpoints;
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
                  Endpoint = "cynerd.cz:51820";
                  AllowedIPs = ["0.0.0.0/0"];
                  PublicKey = config.secrets.wireguardPubs.lipwig;
                }
                // (optionalAttrs (!is_endpoint) {PersistentKeepalive = 25;});
            }
            {
              wireguardPeerConfig =
                {
                  Endpoint = "spt.cynerd.cz:51820";
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
            #      Endpoint = "adm.cynerd.cz:51820";
            #      AllowedIPs = [
            #        "${config.cynerd.hosts.wg.adm-omnia}/32"
            #        "10.8.3.0/24"
            #      ];
            #      PublicKey = config.secrets.wireguardPubs.adm-omnia;
            #    }
            #    // (optionalAttrs (!is_endpoint) {PersistentKeepalive = 25;});
            #}
            {
              wireguardPeerConfig =
                {
                  AllowedIPs = [
                    "${config.cynerd.hosts.wg.dean}/32"
                    "10.0.0.0/22"
                    "10.0.20.0/24"
                  ];
                  PublicKey = config.secrets.wireguardPubs.dean;
                }
                // (optionalAttrs (!is_endpoint) {PersistentKeepalive = 25;});
            }
          ]
          ++ (optionals is_endpoint (mapAttrsToList (n: v: {
            wireguardPeerConfig = {
              AllowedIPs = "${config.cynerd.hosts.wg."${n}"}/32";
              PublicKey = v;
            };
          }) (filterAttrs (n: _: all (v: v != n) endpoints) config.secrets.wireguardPubs)));
      };
      networks."wg" = {
        matchConfig.Name = "wg";
        networkConfig = {
          Address = "${config.cynerd.hosts.wg."${hostName}"}/24";
          IPForward = is_endpoint;
          DNS = mkIf (hostName != "dean") ["10.0.20.30" "10.0.20.31"];
          DNSSEC = false;
          Domains = mkIf (hostName != "dean") "~elektroline.cz";
        };
        routes =
          (optional (hostName != "lipwig") {
            # OpenVPN network
            routeConfig = {
              Gateway = config.cynerd.hosts.wg.lipwig;
              Destination = "10.8.0.0/24";
              Metric = 2048;
            };
          })
          ++ (optional (hostName != "spt-omnia") {
            # SPT network
            routeConfig = {
              Gateway = config.cynerd.hosts.wg.spt-omnia;
              Destination = "10.8.2.0/24";
              Metric = 2048;
            };
          })
          ++ (optional (hostName != "adm-omnia" && hostName != "lipwig") {
            # Adamkovi network
            routeConfig = {
              Gateway = config.cynerd.hosts.wg.adm-omnia;
              Destination = "10.8.3.0/24";
              Metric = 2048;
            };
          })
          ++ (optionals (hostName != "dean") [
            # Elektroline
            {
              routeConfig = {
                Gateway = config.cynerd.hosts.wg.dean;
                Destination = "10.0.0.0/22";
                Metric = 2048;
              };
            }
            {
              routeConfig = {
                Gateway = config.cynerd.hosts.wg.dean;
                Destination = "10.0.20.0/24";
                Metric = 2048;
              };
            }
          ]);
      };
    };
    networking.firewall.allowedUDPPorts = [51820];
  };
}
