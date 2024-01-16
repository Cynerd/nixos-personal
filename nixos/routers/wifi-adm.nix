{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.cynerd.wifiAP.adm;

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
    cynerd.wifiAP.adm = {
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
              ssid = "TurrisAdamkovi";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-TurrisAdamkovi.pass";
              };
            };
            "${cnf.ar9287.interface}.nela" = {
              bssid = "06:f0:21:23:2b:00";
              ssid = "Nela";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-Nela.pass";
              };
            };
            "${cnf.ar9287.interface}.milan" = {
              bssid = "0a:f0:21:23:2b:00";
              ssid = "MILAN-AC";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-MILAN-AC.pass";
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
              ssid = "TurrisAdamkovi";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-TurrisAdamkovi.pass";
              };
            };
            "${cnf.qca988x.interface}.nela" = {
              bssid = "06:f0:21:24:24:d2";
              ssid = "Nela";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-Nela.pass";
              };
            };
            "${cnf.qca988x.interface}.milan" = {
              bssid = "0a:f0:21:24:24:d2";
              ssid = "MILAN-AC";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-MILAN-AC.pass";
              };
            };
          };
        };
      };
    };
    networking = {
      # TODO wlanInterface doesn't work right now because it uses invalid
      # command and seems to just configure only first interface. It is just
      # wrong.
      #wlanInterfaces = {
      #  "${cnf.ar9287.interface}.nela" = {
      #    device = "${cnf.ar9287.interface}";
      #    mac = "06:f0:21:23:2b:00";
      #  };
      #  "${cnf.ar9287.interface}.milan" = {
      #    device = "${cnf.ar9287.interface}";
      #    mac = "0a:f0:21:23:2b:00";
      #  };
      #};
      bridges = {
        brlan.interfaces = filter (v: v != null) [
          cnf.ar9287.interface
          cnf.qca988x.interface
        ];
        brguest.interfaces = optionals (cnf.ar9287.interface != null) [
          "${cnf.ar9287.interface}.nela"
          "${cnf.ar9287.interface}.milan"
        ];
        #  ++ (optionals (cnf.qca988x.interface != null) [
        #    "${cnf.qca988x.interface}.nela"
        #    "${cnf.qca988x.interface}.milan"
        #  ]);
      };
    };
  };
}
