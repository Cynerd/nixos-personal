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
        wan = "pppoe-wan";
        lanIP = config.cynerd.hosts.spt.omnia;
      };
      openvpn.oldpersonal = true;
    };

    networking.vlans."end2.848" = {
      id = 848;
      interface = "end2";
    };
    # TODO pppd service requires end2.848 interface
    services.pppd = {
      enable = true;
      peers."wan".config = ''
        plugin pppoe.so end2.848
        ifname pppoe-wan
        lcp-echo-interval 1
        lcp-echo-failure 5
        lcp-echo-adaptive
        +ipv6
        defaultroute
        defaultroute6
        usepeerdns
        maxfail 1
        user metronet
        password metronet
      '';
    };

    networking.bridges = {
      brlan.interfaces = ["lan0" "lan1" "lan2" "lan3" "lan4"];
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
          ssid = "TurrisRules5";
          wpa = 2;
          wpaPassphrase = "@PASS_TURRIS_RULES@";
          bridge = "brlan";
        };
        "wlp3s0" = {
          countryCode = "CZ";
          hwMode = "g";
          channel = 7;
          ht_capab = ["HT40+" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "DSSS_CCK-40"];
          ssid = "TurrisRules";
          wpa = 2;
          wpaPassphrase = "@PASS_TURRIS_RULES@";
          bridge = "brlan";
        };
      };
    };

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;

      overrideDevices = false;
      overrideFolders = false;

      dataDir = "/data";
    };
  };
}
