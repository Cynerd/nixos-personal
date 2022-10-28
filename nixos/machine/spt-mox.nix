{ config, lib, pkgs, ... }:

with lib;

{

  config = {

    networking.wirelessAP = {
      enable = true;
      environmentFile = "/run/secrets/hostapd.env";
      interfaces = {
        #"mlan0" = {
          #countryCode = "CZ";
          #ssid = "TurrisRules";
          #wpa = true;
          #wpaPassphrase = "@PASS_TURRIS_RULES@";
        #};
        "wlp1s0" = {
          countryCode = "CZ";
          hwMode = "a";
          channel = 40;
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

    networking = {
      vlans = {
        "eth0.2" = {
          id = 2;
          interface = "eth0";
        };
      };
      bridges = {
        brlan = {
          interfaces = [
            "eth0" "lan1" "lan2" "lan3" "lan4"
          ];
        };
        brguest = {
          interfaces = [
            "eth0.2"
          ];
        };
      };
      interfaces.brlan = {
        ipv4 = {
          addresses = [{
            address = config.cynerd.hosts.spt.mox;
            prefixLength = 24;
          }];
        };
      };
      defaultGateway = config.cynerd.hosts.spt.omnia;
      nameservers = [ config.cynerd.hosts.spt.omnia "1.1.1.1" "8.8.8.8" ];
      dhcpcd.allowInterfaces = [ "brlan" ];
    };

  };

}
