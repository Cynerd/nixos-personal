{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkIf mkForce elemAt;
  cnf = config.cynerd.wifiAP.zd;

  wOptions = {
    bssids = mkOption {
      type = with types; listOf str;
      default = [];
      description = "BSSIDs for networks.";
    };
    channel = mkOption {
      type = types.ints.positive;
      description = "Channel to be used";
    };
  };
in {
  options = {
    cynerd.wifiAP.zd = {
      enable = mkEnableOption "Enable Wi-Fi Access Point support (OpenWrt One)";
      wlan0 = wOptions;
      wlan1 = wOptions;
    };
  };

  config = mkIf cnf.enable {
    # TODO regdom doesn't work for some reason
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="CZ"
    '';
    services.hostapd = {
      enable = true;
      radios = {
        "wlan0" = {
          inherit (cnf.wlan0) channel;
          countryCode = "CZ";
          wifi4 = {
            enable = true;
            capabilities = [
              "HT40"
              "SHORT-GI-20"
              "SHORT-GI-40"
              "TX-STBC"
              "RX-STBC1"
              "MAX-AMSDU-7935"
            ];
          };
          networks = {
            "wlan0" = {
              bssid = elemAt cnf.wlan0.bssids 0;
              ssid = "UNas";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-UNas.pass";
              };
            };
            "wlan0.guest" = {
              bssid = elemAt cnf.wlan0.bssids 1;
              ssid = "Koci";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-Koci.pass";
              };
            };
            "wlan0.iotd" = {
              bssid = elemAt cnf.wlan0.bssids 2;
              ssid = "IOTD";
              authentication = {
                mode = "wpa2-sha256";
                wpaPasswordFile = "/run/secrets/hostapd-IOTD.pass";
              };
              settings = {
                ieee80211w = mkForce 0;
                wpa_key_mgmt = mkForce "WPA-PSK"; # force use without sha256
              };
            };
          };
        };
        #"wlan1" = {
        #};
      };
    };
    systemd.network.networks = {
      "lan-wlan0" = {
        matchConfig = {
          Name = "wlan0 wlan0.iotd";
          WLANInterfaceType = "ap";
        };
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 1;
            PVID = 1;
          }
        ];
      };
      "lan-wlan0-guest" = {
        matchConfig.Name = "wlan0.guest";
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 2;
            PVID = 2;
          }
        ];
      };
    };
  };
}
