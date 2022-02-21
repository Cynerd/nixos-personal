{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd.desktop.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/3b3063aa-c284-4075-bb37-8820df12a2f5";
        options = ["compress=lzo" "subvol=@nix"];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/3b3063aa-c284-4075-bb37-8820df12a2f5";
        options = ["compress=lzo" "subvol=@home"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/C1A0-B7C9";
      };

      "/home2" = {
        device = "/dev/disk/by-uuid/c9aa0b7b-7482-4d4a-bcc3-8bd6a853ae7f";
        options = ["compress=lzo" "subvol=@home"];
      };
    };

  };

}
