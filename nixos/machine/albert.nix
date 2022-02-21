{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd.desktop.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/1c9bafac-fcf8-41c4-b394-bca5917ca82d";
        options = ["compress=lzo" "subvol=@nix"];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/1c9bafac-fcf8-41c4-b394-bca5917ca82d";
        options = ["compress=lzo" "subvol=@home"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/E403-124B";
      };

      "/home2" = {
        device = "/dev/disk/by-uuid/55e177a1-215e-475b-ba9c-771b5fa3f8f0";
        options = ["compress=lzo" "subvol=@home"];
      };
    };

  };

}
