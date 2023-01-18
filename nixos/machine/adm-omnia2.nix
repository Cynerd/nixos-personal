{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    networking = {
      bridges.brlan.interfaces = [
        "end2" "lan0" "lan1" "lan2" "lan3" "lan4"
      ];
      interfaces.brlan.ipv4.addresses = [
        {
          address = config.cynerd.hosts.adm.omnia2;
          prefixLength = 24;
        }
      ];
      defaultGateway = config.cynerd.hosts.adm.omnia;
      nameservers = ["1.1.1.1" "8.8.8.8"];
      dhcpcd.allowInterfaces = ["lan"];
    };

    networking.wirelessAP = {
      enable = true;
      environmentFile = "/run/secrets/hostapd.env";
      interfaces = {
        "wlp2s0" = {
          countryCode = "CZ";
          hwMode = "a";
          channel = 36;
          ieee80211ac = true;
          ht_capab = ["HT40+" "LDPC" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "MAX-AMSDU-7935" "DSSS_CCK-40"];
          vht_capab = ["RXLDPC" "SHORT-GI-80" "TX-STBC-2BY1" "RX-ANTENNA-PATTERN" "TX-ANTENNA-PATTERN" "RX-STBC-1" "MAX-MPDU-11454" "MAX-A-MPDU-LEN-EXP7"];
          ssid = "TurrisAdamkovi5";
          wpa = 2;
          wpaPassphrase = "@PASS_TURRIS_ADAMKOVI@";
          bridge = "brlan";
        };
        "wlp3s0" = {
          countryCode = "CZ";
          hwMode = "g";
          channel = 7;
          ht_capab = ["HT40+" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "DSSS_CCK-40"];
          ssid = "TurrisAdamkovi";
          wpa = 2;
          wpaPassphrase = "@PASS_TURRIS_ADAMKOVI@";
          bridge = "brlan";
        };
      };
    };
  };
}
