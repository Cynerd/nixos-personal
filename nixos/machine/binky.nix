{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd = {
      desktop = {
        enable = true;
        laptop = true;
      };
      wifiClient = true;
      develop = true;
    };

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod"];
    boot.kernelModules = ["kvm-amd"];

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
    services.openvpn.servers.oldpersonal = {
      config = "config /run/secrets/old.ovpn";
    };
    services.openvpn.servers.elektroline = {
      config = "config /run/secrets/elektroline.ovpn";
    };

    cynerd.gaming = true;

  };

}
