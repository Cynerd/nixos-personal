{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd.desktop.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/b4b3dd52-29d0-4cb9-91c9-694dfcd9672c";
        options = ["compress=lzo" "subvol=@nix"];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/b4b3dd52-29d0-4cb9-91c9-694dfcd9672c";
        options = ["compress=lzo" "subvol=@home"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/87B0-A1D5";
      };

      "/home2" = {
        device = "/dev/disk/by-uuid/259d078f-b3d9-4bcc-90cc-6a0d7271a03d";
        options = ["compress=lzo" "subvol=@home"];
      };
      "/var/build" = {
        device = "/dev/disk/by-uuid/259d078f-b3d9-4bcc-90cc-6a0d7271a03d";
        options = ["compress=lzo" "subvol=@build" "uid=build" "gid=build"];
      };
    };

  };

}
