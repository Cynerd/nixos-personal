{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd = {
      #openvpn.oldpersonal = true;
    };
    boot.kernelPackages = pkgs.linuxPackages;

    networking = {
      # TODO we need vlan filtering to filter out guest and adm network
      bridges = {
        brlan = {
          interfaces = [
            "lan0" "lan1" "lan2" "lan3" "lan4"
          ];
        };
        #brguest = {
        #  interfaces = [
        #    "brlan.2" #"mlan0host" "wlp1s0host"
        #  ];
        #};
      };
      interfaces.brlan = {
        ipv4 = {
          addresses = [{
            address = config.cynerd.hosts.adm.omnia;
            prefixLength = 24;
          }];
        };
      };
      # TODO localhost
      nameservers = [ "1.1.1.1" "8.8.8.8" ];
      dhcpcd.allowInterfaces = [ "eth2" ];
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
          wpa = true;
          wpaPassphrase = "@PASS_TURRIS_RULES@";
          bss = {
            "wlp1s0host" = {
              ssid = "KocoviGuest";
              wpa = true;
              wpaPassphrase = "@PASS_KOCOVI@";
            };
          };
        };
      };
    };

  };

}
