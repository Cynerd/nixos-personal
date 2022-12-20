{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    fileSystems = {
      "/" = {
        device = "/dev/mmcblk0p1";
        fsType = "btrfs";
        options = ["compress=lzo"];
      };
    };
  };

}
