{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd = {
      openvpn.oldpersonal = true;
    };

    services.syncthing = {
      enable = true;
      #user = mkDefault "cynerd";
      #group = mkDefault "cynerd";
      openDefaultPorts = true;

      overrideDevices = false;
      overrideFolders = false;

      dataDir = "/data";
      configDir = "/srv/syncthing";
    };

  };

}
