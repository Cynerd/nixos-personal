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
      countryCode = "CZ";
      environmentFile = "/run/secrets/hostapd.env";
      interfaces =
        (optionalAttrs (cnf.ar9287.interface != null) {
          "${cnf.ar9287.interface}" = hostapd.qualcomAtherosAR9287 {
            channel = cnf.ar9287.channel;
            bssid = "@BSSID_AR9287_0@";
            ssid = "TurrisRules";
            wpa = 2;
            wpaPassphrase = "@PASS_TURRIS_RULES@";
            bridge = "brlan";
            bss = {
              "${cnf.ar9287.interface}.guest" = {
                bssid = "@BSSID_AR9287_1@";
                ssid = "Kocovi";
                wpa = 2;
                wpaPassphrase = "@PASS_KOCOVI@";
                bridge = "brguest";
              };
            };
          };
        })
        // (optionalAttrs (cnf.qca988x.interface != null) {
          "${cnf.qca988x.interface}" = hostapd.qualcomAtherosQCA988x {
            channel = cnf.qca988x.channel;
            bssid = "@BSSID_QCA988X_0@";
            ssid = "TurrisRules5";
            wpa = 2;
            wpaPassphrase = "@PASS_TURRIS_RULES@";
            bridge = "brlan";
            bss = {
              "${cnf.qca988x.interface}.guest" = {
                bssid = "@BSSID_QCA988X_1@";
                ssid = "Kocovi";
                wpa = 2;
                wpaPassphrase = "@PASS_KOCOVI@";
                bridge = "brguest";
              };
            };
          };
        });
    };
  };
}
