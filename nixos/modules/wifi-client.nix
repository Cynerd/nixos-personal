{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf;
in {
  options = {
    cynerd.wifiClient = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Wi-Fi client support";
    };
  };

  config = mkIf config.cynerd.wifiClient {
    environment.systemPackages = with pkgs; [
      wpa_supplicant_gui
    ];
    networking.wireless = {
      enable = true;
      networks = config.secrets.wifiNetworks;
      secretsFile = "/run/secrets/wifi.secrets";
      userControlled.enable = true;
    };
  };
}
