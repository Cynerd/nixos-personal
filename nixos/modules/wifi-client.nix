{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options = {
    cynerd.wifiClient = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Wi-Fi client support";
    };
  };

  config = mkIf config.cynerd.wifiClient {
    networking.wireless = {
      enable = true;
      networks = config.secrets.wifiNetworks;
      environmentFile = "/run/secrets/wifi.env";
      userControlled.enable = true;
    };
  };
}
