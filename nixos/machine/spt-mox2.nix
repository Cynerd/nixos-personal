{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    swapDevices = [
      {
        device = "/dev/disk/by-partlabel/NixTurrisSwap";
        priority = 1;
      }
    ];

    networking.wirelessAP = {
      enable = true;
      environmentFile = "/run/secrets/hostapd.env";
      interfaces = {
        "wls1" = {
          countryCode = "CZ";
          channel = 7;
          hwMode = "g";
          ht_capab = ["LDPC" "HT40+" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "MAX-AMSDU-7935" "DSSS_CCK-40"];
          ssid = "TurrisRules";
          bridge = "brlan";
          wpa = true;
          wpa3 = false;
          wpaPassphrase = "@PASS_TURRIS_RULES@";
          #bss = {
          #  "wlp1s0host" = {
          #    ssid = "KocoviGuest";
          #    wpa = true;
          #    wpaPassphrase = "@PASS_KOCOVI@";
          #  };
          #};
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
            "eth0"
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
              address = config.cynerd.hosts.spt.mox2;
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
