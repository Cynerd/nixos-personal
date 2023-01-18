{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    cynerd = {
      router = {
        enable = true;
        wan = "end2";
        lanIP = config.cynerd.hosts.adm.omnia;
      };
      openvpn.oldpersonal = false;
    };

    networking.bridges = {
      brlan.interfaces = ["lan0" "lan1" "lan2" "lan3" "lan4"];
    };

    networking.wirelessAP = {
      enable = true;
      environmentFile = "/run/secrets/hostapd.env";
      interfaces = {
        "wlp1s0" = {
          countryCode = "CZ";
          hwMode = "a";
          channel = 36;
          ieee80211ac = true;
          ht_capab = ["HT40+" "LDPC" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "MAX-AMSDU-7935" "DSSS_CCK-40"];
          vht_capab = ["RXLDPC" "SHORT-GI-80" "TX-STBC-2BY1" "RX-ANTENNA-PATTERN" "TX-ANTENNA-PATTERN" "RX-STBC-1" "MAX-MPDU-11454" "MAX-A-MPDU-LEN-EXP7"];
          ssid = "TurrisRules5";
          wpa = 2;
          wpaPassphrase = "@PASS_TURRIS_RULES@";
          bss = {
            "wlp1s0host" = {
              ssid = "KocoviGuest";
              wpa = 2;
              wpaPassphrase = "@PASS_KOCOVI@";
            };
          };
        };
      };
    };
  };
}
