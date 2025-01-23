{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkIf mkForce mkMerge hostapd elemAt;
  cnf = config.cynerd.wifiAP.spt;

  wifi-networks = name: let
    is2g = cnf."${name}".channel <= 14;
  in {
    "${cnf."${name}".interface}" = {
      bssid = elemAt cnf."${name}".bssids 0;
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
    "${cnf."${name}".interface}.guest" = {
      bssid = elemAt cnf."${name}".bssids 1;
      ssid = "Kocovi";
      authentication = {
        mode = "wpa2-sha256";
        wpaPasswordFile = "/run/secrets/hostapd-Kocovi.pass";
      };
    };
  };

  net-networks = name: {
    "lan-${cnf."${name}".interface}" = {
      matchConfig = {
        Name = cnf."${name}".interface;
        WLANInterfaceType = "ap";
      };
      networkConfig.Bridge = "brlan";
      bridgeVLANs = [
        {
          EgressUntagged = 1;
          PVID = 1;
        }
      ];
    };
    "lan-${cnf."${name}".interface}-guest" = {
      matchConfig.Name = "${cnf."${name}".interface}.guest";
      networkConfig.Bridge = "brlan";
      bridgeVLANs = [
        {
          EgressUntagged = 2;
          PVID = 2;
        }
      ];
    };
  };

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
            networks = wifi-networks "ar9287";
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
            networks = wifi-networks "qca988x";
          };
        })
      ];
    };
    systemd.network.networks = mkMerge [
      (mkIf (cnf.ar9287.interface != null) (net-networks "ar9287"))
      (mkIf (cnf.qca988x.interface != null) (net-networks "qca988x"))
    ];
  };
}
