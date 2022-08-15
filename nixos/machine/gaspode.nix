{ config, lib, pkgs, ... }:

with lib;

{

  config = {

    fileSystems = {
      "/" = {
        device = "/dev/mmcblk0p2";
        options = ["compress=lzo" "subvol=@nix"];
      };
      "/home" = {
        device = "/dev/mmcblk0p2";
        options = ["compress=lzo" "subvol=@home"];
      };
      "/boot" = {
        device = "/dev/mmcblk0p1";
      };
    };

  };

}
