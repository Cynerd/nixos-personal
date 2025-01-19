{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkIf hostapd elemAt;
  cnf = config.cynerd.wifiAP.adm;

  networks = name: {
    "${cnf."${name}".interface}" = {
      bssid = elemAt cnf."${name}".bssids 0;
      ssid = "TurrisAdamkovi";
      authentication = {
        mode = "wpa3-sae-transition";
        wpaPasswordFile = "/run/secrets/hostapd-TurrisAdamkovi.pass";
        saePasswordsFile = "/run/secrets/hostapd-TurrisAdamkovi.pass";
      };
    };
    "${cnf."${name}".interface}-nela" = {
      bssid = elemAt cnf."${name}".bssids 1;
      ssid = "Nela";
      authentication = {
        mode = "wpa2-sha256";
        wpaPasswordFile = "/run/secrets/hostapd-Nela.pass";
      };
    };
    "${cnf."${name}".interface}.milan" = {
      bssid = elemAt cnf."${name}".bssids 2;
      ssid = "MILAN-AC";
      authentication = {
        mode = "wpa2-sha1";
        wpaPasswordFile = "/run/secrets/hostapd-MILAN-AC.pass";
      };
    };
  };

  wOptions = card: channelDefault: {
    interface = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Specify interface for ${card}";
    };
    bssids = mkOption {
      type = with types; listOf str;
      default = [];
      description = "BSSIDs for networks.";
    };
    channel = mkOption {
      type = types.ints.positive;
      default = channelDefault;
      description = "Channel to be used for ${card}";
    };
  };
in {
  options = {
    cynerd.wifiAP.adm = {
      enable = mkEnableOption "Enable Wi-Fi Access Point support";
      ar9287 = wOptions "Qualcom Atheros AR9287" 7;
      qca988x = wOptions "Qualcom Atheros QCA988x" 36;
    };
  };

  config = mkIf cnf.enable {
    services.hostapd = {
      enable = true;
      radios = {
        "${cnf.ar9287.interface}" = mkIf (cnf.ar9287.interface != null) {
          countryCode = "CZ";
          inherit (cnf.ar9287) channel;
          wifi4 = {
            enable = true;
            inherit (hostapd.qualcomAtherosAR9287.wifi4) capabilities;
          };
          networks = networks "ar9287";
        };
        "${cnf.qca988x.interface}" = mkIf (cnf.qca988x.interface != null) {
          countryCode = "CZ";
          inherit (cnf.qca988x) channel;
          band = "5g";
          wifi4 = {
            enable = true;
            inherit (hostapd.qualcomAtherosQCA988x.wifi4) capabilities;
          };
          wifi5 = {
            enable = true;
            inherit (hostapd.qualcomAtherosQCA988x.wifi5) capabilities;
          };
          networks = networks "qca988x";
        };
      };
    };
    systemd.network.networks = {
      "lan-${cnf.ar9287.interface}" = {
        matchConfig.Name = cnf.ar9287.interface;
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 1;
            PVID = 1;
          }
        ];
      };
      "lan-${cnf.ar9287.interface}-nela" = {
        matchConfig.Name = "${cnf.ar9287.interface}-nela";
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 2;
            PVID = 2;
          }
        ];
      };
      "lan-${cnf.ar9287.interface}.milan" = {
        matchConfig.Name = "${cnf.ar9287.interface}.milan";
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 2;
            PVID = 2;
          }
        ];
      };
      "lan-${cnf.qca988x.interface}" = {
        matchConfig.Name = cnf.qca988x.interface;
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 1;
            PVID = 1;
          }
        ];
      };
      "lan-${cnf.qca988x.interface}-nela" = {
        matchConfig.Name = "${cnf.qca988x.interface}-nela";
        networkConfig.Bridge = "brlan";
        bridgeVLANs = [
          {
            EgressUntagged = 2;
            PVID = 2;
          }
        ];
      };
      "lan-${cnf.qca988x.interface}.milan" = {
        matchConfig.Name = "${cnf.qca988x.interface}.milan";
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
