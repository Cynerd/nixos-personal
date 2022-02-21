{ config, lib, pkgs, ... }:

with lib;

{

  config = {

    #boot.kernelPatches = [{
    #  name = "rwtm";
    #  patch = null;
    #  extraConfig = ''
    #    TURRIS_MOX_RWTM y
    #    ARMADA_37XX_RWTM_MBOX y
    #    '';
    #}];

    networking.hostapd = {
      "mlan0" = {
        countryCode = "CZ";
        ssid = "TurrisRules";
        wpa = true;
        wpaPskFile = "/run/secrets/wifi/TurrisRules.psk";
      };
      "wlp1s0" = {
        countryCode = "CZ";
        hwMode = "a";
        channel = 36;
        ieee80211ac = true;
        ht_capab = ["HT40+" "LDPC" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "MAX-AMSDU-7935" "DSSS_CCK-40"];
        vht_capab = ["RXLDPC" "SHORT-GI-80" "TX-STBC-2BY1" "RX-ANTENNA-PATTERN" "TX-ANTENNA-PATTERN" "RX-STBC-1" "MAX-MPDU-11454" "MAX-A-MPDU-LEN-EXP7"];
        ssid = "TurrisRules5";
        wpa = true;
        wpaPskFile = "/run/secrets/wifi/TurrisRules5.psk";
        bss = {
          "wlp1s0host" = {
            ssid = "NixTurris5Guest";
            wpa = true;
            wpaPassphrase = "somepassword";
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
            "eth0" #"mlan0" "wlp1s0"
          ];
        };
        brguest = {
          interfaces = [
            "eth0.2" #"mlan0host" "wlp1s0host"
          ];
        };
      };
      interfaces.brlan = {
        ipv4 = {
          addresses = [{
            address = config.cynerd.hosts.spt.mox2;
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
