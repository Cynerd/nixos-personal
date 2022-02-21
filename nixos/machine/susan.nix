{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd.desktop.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/e092a3ad-fb32-44fa-bc1f-14c2733da033";
        options = ["compress=lzo" "subvol=@nix"];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/e092a3ad-fb32-44fa-bc1f-14c2733da033";
        options = ["compress=lzo" "subvol=@home"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/EB3E-3635";
      };
    };

  };

}
