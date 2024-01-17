{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.cynerd.wifiAP.spt;

  wOptions = card: channelDefault: {
    interface = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Specify interface for ${card}";
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
    services.hostapd = {
      enable = true;
      radios = {
        "${cnf.ar9287.interface}" = mkIf (cnf.ar9287.interface != null) {
          countryCode = "CZ";
          inherit (cnf.ar9287) channel;
          wifi4 = {
            enable = true;
            inherit (hostapd.qualcomAtherosAR9287.wifi4) capabilities;
          };
          networks = {
            "${cnf.ar9287.interface}" = {
              bssid = "02:f0:21:23:2b:00";
              ssid = "TurrisRules";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-TurrisRules.pass";
              };
            };
            "${cnf.ar9287.interface}.guest" = {
              bssid = "0a:f0:21:23:2b:00";
              ssid = "Kocovi";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-Kocovi.pass";
              };
            };
          };
        };
        "${cnf.qca988x.interface}" = mkIf (cnf.qca988x.interface != null) {
          countryCode = "CZ";
          inherit (cnf.qca988x) channel;
          band = "5g";
          wifi4 = {
            enable = true;
            inherit (hostapd.qualcomAtherosQCA988x.wifi4) capabilities;
          };
          wifi5 = {
            enable = true;
            inherit (hostapd.qualcomAtherosQCA988x.wifi5) capabilities;
          };
          networks = {
            "${cnf.qca988x.interface}" = {
              bssid = "04:f0:21:24:24:d2";
              ssid = "TurrisRules5";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-TurrisRules.pass";
              };
            };
            "${cnf.qca988x.interface}.guest" = {
              bssid = "0a:f0:21:24:24:d2";
              ssid = "Kocovi";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-Kocovi.pass";
              };
            };
          };
        };
      };
    };
    systemd.network.networks = {
      "lan-${cnf.ar9287.interface}" = {
        matchConfig.Name = cnf.ar9287.interface;
        networkConfig.Bridge = "brlan";
      };
      "lan-${cnf.ar9287.interface}.guest" = {
        matchConfig.Name = "${cnf.ar9287.interface}.guest";
        networkConfig.Bridge = "brguest";
      };
      "lan-${cnf.qca988x.interface}" = {
        matchConfig.Name = cnf.qca988x.interface;
        networkConfig.Bridge = "brlan";
      };
      "lan-${cnf.qca988x.interface}.guest" = {
        matchConfig.Name = "${cnf.qca988x.interface}.guest";
        networkConfig.Bridge = "brguest";
      };
    };
  };
}
