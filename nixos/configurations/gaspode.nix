{
  nixpkgs.hostPlatform.system = "armv7l-linux";

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
}
