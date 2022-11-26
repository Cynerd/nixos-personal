{ config, lib, pkgs, ... }:

with lib;

{

  config = {
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

    cynerd.autounlock = {
      "encroot" = "/dev/disk/by-uuid/c07e929a-6eac-4f99-accf-f7cb3431290c";
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
        device = "/dev/disk/by-uuid/C1A0-B7C9";
        fsType = "vfat";
      };

      "/home2" = {
        device = "/dev/mapper/enchdd";
        fsType = "btrfs";
        options = ["compress=lzo" "subvol=@home"];
      };
    };

    networking.vlans."enp6s0.adm" = {
      id = 2;
      interface = "enp6s0";
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

  };

}
