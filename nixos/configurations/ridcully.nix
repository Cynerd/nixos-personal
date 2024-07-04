{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  nixpkgs.hostPlatform.system = "x86_64-linux";
  deploy.enable = true;

  cynerd = {
    desktop.enable = true;
    develop = true;
    gaming = true;
    openvpn = {
      elektroline = true;
    };
  };

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage"];
  boot.kernelModules = ["kvm-amd"];

  hardware.cpu.amd.updateMicrocode = true;
  services.hardware.openrgb.motherboard = "amd";

  cynerd.autounlock = {
    "encroot" = "/dev/disk/by-uuid/bc7d2ba4-6e04-4c49-b40c-3aecd1a86c71";
    "enchdd" = "/dev/disk/by-uuid/7fee3cda-efa0-47cd-8832-fdead9a7e6db";
  };
  fileSystems = {
    "/" = {
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
      device = "/dev/disk/by-uuid/6DAD-3819";
      fsType = "vfat";
    };

    "/home2" = {
      device = "/dev/mapper/enchdd";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@home"];
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/" "/home2"];
  };

  networking = {
    useNetworkd = true;
    useDHCP = true;
  };
  systemd.network = {
    wait-online.enable = false;
  };
  #networking.vlans."enp6s0.adm" = {
  #id = 2;
  #interface = "enp6s0";
  #};

  environment.systemPackages = [
    pkgs.nvtopPackages.amd
  ];

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

  # Force nix to use less jobs
  nix.settings.max-jobs = 8;
}
