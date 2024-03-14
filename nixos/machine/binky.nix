{lib, ...}: let
  inherit (lib) mkDefault;
in {
  deploy = {
    enable = true;
    default = false;
  };

  cynerd = {
    desktop = {
      enable = true;
      laptop = true;
    };
    wifiClient = true;
    develop = true;
    openvpn = {
      oldpersonal = true;
      elektroline = true;
    };
  };

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-amd"];
  };

  hardware.cpu.amd.updateMicrocode = true;

  boot.initrd.luks.devices = {
    "encroot".device = "/dev/disk/by-uuid/b317feb5-d68d-4ec3-a24f-0307c116cac8";
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@"];
    };
    "/nix" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@nix"];
    };
    "/home" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@home"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8F7D-A154";
      fsType = "vfat";
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
  };

  services.syncthing = {
    enable = true;
    user = mkDefault "cynerd";
    group = mkDefault "cynerd";
    openDefaultPorts = true;

    overrideDevices = false;
    overrideFolders = false;

    dataDir = "/home/cynerd";
    configDir = "/home/cynerd/.config/syncthing";
  };
}
