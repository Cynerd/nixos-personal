{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkIf mkForce mkMerge hostapd elemAt;
  cnf = config.cynerd.wifiAP.spt;

  wOptions = card: channelDefault: {
    interface = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Specify interface for ${card}";
    };
    bssids = mkOption {
      type = with types; listOf str;
      default = [];
      description = "BSSIDs for networks.";
    };
    channel = mkOption {
      type = types.ints.positive;
      default = channelDefault;
      description = "Channel to be used for ${card}";
    };
  };
in {
  options = {
    cynerd.wifiAP.spt = {
      enable = mkEnableOption "Enable Wi-Fi Access Point support";
      ar9287 = wOptions "Qualcom Atheros AR9287" 7;
      qca988x = wOptions "Qualcom Atheros QCA988x" 36;
    };
  };

  config = mkIf cnf.enable {
    # TODO regdom doesn't work for some reason
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="CZ"
    '';
    services.hostapd = {
      enable = true;
      radios = mkMerge [
        (mkIf (cnf.ar9287.interface != null) {
          "${cnf.ar9287.interface}" = {
            inherit (cnf.ar9287) channel;
            countryCode = "CZ";
            wifi4 = {
              enable = true;
              inherit (hostapd.qualcomAtherosAR9287.wifi4) capabilities;
            };
            networks = {
              "${cnf.ar9287.interface}" = {
                bssid = elemAt cnf.ar9287.bssids 0;
                ssid = "TurrisRules";
                authentication = {
                  mode = "wpa2-sha256";
                  wpaPasswordFile = "/run/secrets/hostapd-TurrisRules.pass";
                };
                settings = {
                  ieee80211w = 0;
                  wpa_key_mgmt = mkForce "WPA-PSK"; # force use without sha256
                };
              };
              #"${cnf.ar9287.interface}.guest" = {
              #  bssid = elemAt cnf.ar9287.bssids 1;
              #  ssid = "Kocovi";
              #  authentication = {
              #    mode = "wpa2-sha256";
              #    wpaPasswordFile = "/run/secrets/hostapd-Kocovi.pass";
              #  };
              #};
            };
          };
        })
        (mkIf (cnf.qca988x.interface != null) {
          "${cnf.qca988x.interface}" = let
            is2g = cnf.qca988x.channel <= 14;
          in {
            inherit (cnf.qca988x) channel;
            countryCode = "CZ";
            band =
              if is2g
              then "2g"
              else "5g";
            wifi4 = {
              enable = true;
              inherit (hostapd.qualcomAtherosQCA988x.wifi4) capabilities;
            };
            wifi5 = {
              enable = !is2g;
              inherit (hostapd.qualcomAtherosQCA988x.wifi5) capabilities;
            };
            networks = {
              "${cnf.qca988x.interface}" = {
                bssid = elemAt cnf.qca988x.bssids 0;
                ssid = "TurrisRules${
                  if is2g
                  then ""
                  else "5"
                }";
                authentication = {
                  mode = "wpa2-sha256";
                  wpaPasswordFile = "/run/secrets/hostapd-TurrisRules.pass";
                };
                settings = mkIf is2g {
                  ieee80211w = 0;
                  wpa_key_mgmt = mkForce "WPA-PSK"; # force use without sha256
                };
              };
              #"${cnf.qca988x.interface}.guest" = {
              #  bssid = elemAt cnf.qca988x.bssids 1;
              #  ssid = "Kocovi";
              #  authentication = {
              #    mode = "wpa2-sha256";
              #    wpaPasswordFile = "/run/secrets/hostapd-Kocovi.pass";
              #  };
              #};
            };
          };
        })
      ];
    };
    systemd.network.networks = mkMerge [
      (mkIf (cnf.ar9287.interface != null) {
        "lan-${cnf.ar9287.interface}" = {
          matchConfig = {
            Name = cnf.ar9287.interface;
            WLANInterfaceType = "ap";
          };
          networkConfig.Bridge = "brlan";
          bridgeVLANs = [
            {
              bridgeVLANConfig = {
                EgressUntagged = 1;
                PVID = 1;
              };
            }
          ];
        };
        #"lan-${cnf.ar9287.interface}-guest" = {
        #  matchConfig.Name = "${cnf.ar9287.interface}.guest";
        #  networkConfig.Bridge = "brlan";
        #  bridgeVLANs = [
        #    {
        #      bridgeVLANConfig = {
        #        EgressUntagged = 2;
        #        PVID = 2;
        #      };
        #    }
        #  ];
        #};
      })
      (mkIf (cnf.qca988x.interface != null) {
        "lan-${cnf.qca988x.interface}" = {
          matchConfig = {
            Name = cnf.qca988x.interface;
            WLANInterfaceType = "ap";
          };
          networkConfig.Bridge = "brlan";
          bridgeVLANs = [
            {
              bridgeVLANConfig = {
                EgressUntagged = 1;
                PVID = 1;
              };
            }
          ];
        };
        #"lan-${cnf.qca988x.interface}-guest" = {
        #  matchConfig.Name = "${cnf.qca988x.interface}.guest";
        #  networkConfig.Bridge = "brlan";
        #  bridgeVLANs = [
        #    {
        #      bridgeVLANConfig = {
        #        EgressUntagged = 2;
        #        PVID = 2;
        #      };
        #    }
        #  ];
        #};
      })
    ];
  };
}
