{inputModules, ...}: {
  imports = [inputModules.nixos-hardware.raspberry-pi-2];

  config = {
    system.stateVersion = "24.05";
    nixpkgs.hostPlatform.system = "armv7l-linux";

    fileSystems = {
      "/" = {
        device = "/dev/mmcblk0p1";
        fsType = "btrfs";
        options = ["compress=lzo"];
      };
    };
  };
}
