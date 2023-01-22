{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.cynerd.wifiAP.adm;

  wOptions = band: channelDefault: {
    interface = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Specify interface for ${band}";
    };
    channel = mkOption {
      type = types.ints.positive;
      default = channelDefault;
      description = "Channel to be used for ${band} range";
    };
  };
in {
  options = {
    cynerd.wifiAP.adm = {
      enable = mkEnableOption "Enable Wi-Fi Access Point support";
      w24 = wOptions "2.4GHz" 7;
      w5 = wOptions "5GHz" 36;
    };
  };

  config = mkIf cnf.enable {
    networking.wirelessAP = {
      enable = true;
      environmentFile = "/run/secrets/hostapd.env";
      interfaces =
        (optionalAttrs (cnf.w24.interface != null) {
          "${cnf.w24.interface}" = {
            bssid = "@BSSID_W24_0@";
            countryCode = "CZ";
            hwMode = "g";
            channel = cnf.w24.channel;
            ht_capab = ["HT40+" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "DSSS_CCK-40"];
            ssid = "TurrisAdamkovi";
            wpa = 2;
            wpaPassphrase = "@PASS_TURRIS_ADAMKOVI@";
            bridge = "brlan";
            bss = {
              "wlp3s0.nela" = {
                bssid = "@BSSID_W24_1@";
                ssid = "Nela";
                wpa = 2;
                wpaPassphrase = "@PASS_NELA@";
                bridge = "brguest";
              };
              "wlp3s0.milan" = {
                bssid = "@BSSID_W24_2@";
                ssid = "MILAN-AC";
                wpa = 2;
                wpaPassphrase = "@PASS_MILAN_AC@";
                bridge = "brguest";
              };
            };
          };
        })
        // (optionalAttrs (cnf.w5.interface != null) {
          "${cnf.w5.interface}" = {
            bssid = "@BSSID_W5_0@";
            countryCode = "CZ";
            hwMode = "a";
            channel = cnf.w5.channel;
            ieee80211ac = true;
            ht_capab = ["HT40+" "LDPC" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "MAX-AMSDU-7935" "DSSS_CCK-40"];
            vht_capab = ["RXLDPC" "SHORT-GI-80" "TX-STBC-2BY1" "RX-ANTENNA-PATTERN" "TX-ANTENNA-PATTERN" "RX-STBC-1" "MAX-MPDU-11454" "MAX-A-MPDU-LEN-EXP7"];
            ssid = "TurrisAdamkovi5";
            wpa = 2;
            wpaPassphrase = "@PASS_TURRIS_ADAMKOVI@";
            bridge = "brlan";
            bss = {
              "wlp2s0.nela" = {
                bssid = "@BSSID_W5_1@";
                ssid = "Nela5";
                wpa = 2;
                wpaPassphrase = "@PASS_NELA@";
                bridge = "brguest";
              };
              "wlp2s0.milan" = {
                bssid = "@BSSID_W5_2@";
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
