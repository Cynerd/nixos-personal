{
  fileSystems = {
    "/" = {
      device = "/dev/mmcblk0p1";
      fsType = "btrfs";
      options = ["compress=lzo"];
    };
  };
}
