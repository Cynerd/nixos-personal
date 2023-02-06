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
      countryCode = "CZ";
      environmentFile = "/run/secrets/hostapd.env";
      interfaces =
        (optionalAttrs (cnf.ar9287.interface != null) {
          "${cnf.ar9287.interface}" = hostapd.qualcomAtherosAR9287 {
            inherit (cnf.ar9287) channel;
            bssid = "@BSSID_AR9287_0@";
            ssid = "TurrisAdamkovi";
            wpa = 2;
            wpaPassphrase = "@PASS_TURRIS_ADAMKOVI@";
            bridge = "brlan";
            bss = {
              "${cnf.ar9287.interface}.nela" = {
                bssid = "@BSSID_AR9287_1@";
                ssid = "Nela";
                wpa = 2;
                wpaPassphrase = "@PASS_NELA@";
                bridge = "brguest";
              };
              "${cnf.ar9287.interface}.milan" = {
                bssid = "@BSSID_AR9287_2@";
                ssid = "MILAN-AC";
                wpa = 2;
                wpaPassphrase = "@PASS_MILAN_AC@";
                bridge = "brguest";
              };
            };
          };
        })
        // (optionalAttrs (cnf.qca988x.interface != null) {
          "${cnf.qca988x.interface}" = hostapd.qualcomAtherosQCA988x {
            inherit (cnf.qca988x) channel;
            bssid = "@BSSID_AR9287_0@";
            ssid = "TurrisAdamkovi5";
            wpa = 2;
            wpaPassphrase = "@PASS_TURRIS_ADAMKOVI@";
            bridge = "brlan";
            bss = {
              "${cnf.qca988x.interface}.nela" = {
                bssid = "@BSSID_AR9287_1@";
                ssid = "Nela5";
                wpa = 2;
                wpaPassphrase = "@PASS_NELA@";
                bridge = "brguest";
              };
              "${cnf.qca988x.interface}.milan" = {
                bssid = "@BSSID_AR9287_2@";
                ssid = "MILAN-AC";
                wpa = 2;
                wpaPassphrase = "@PASS_MILAN_AC@";
                bridge = "brguest";
              };
            };
          };
        });
    };
  };
}
