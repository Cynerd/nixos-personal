{
  config,
  lib,
  pkgs,
  ...
}:
with builtins;
with lib; {
  config = {
    cynerd.home-assistant = true;

    networking.wirelessAP = {
      enable = true;
      environmentFile = "/run/secrets/hostapd.env";
      interfaces = {
        "wls1" = {
          countryCode = "CZ";
          channel = 7;
          hwMode = "g";
          ht_capab = ["HT40+" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "DSSS_CCK-40"];
          ssid = "TurrisRules";
          bridge = "brlan";
          wpa = true;
          wpa3 = false;
          wpaPassphrase = "@PASS_TURRIS_RULES@";
        };
        # TODO use use wlp3s0 with 80211ax
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
            "eth0"
            "lan1"
            "lan2"
            "lan3"
            "lan4"
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
          addresses = [
            {
              address = config.cynerd.hosts.spt.mox;
              prefixLength = 24;
            }
          ];
        };
      };
      defaultGateway = config.cynerd.hosts.spt.omnia;
      nameservers = [config.cynerd.hosts.spt.omnia "1.1.1.1" "8.8.8.8"];
      dhcpcd.allowInterfaces = ["brlan"];
    };
  };
}
