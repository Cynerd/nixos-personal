{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
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
      "encroot" = "/dev/disk/by-uuid/8095988e-239b-4417-9df6-94a40e4133ed";
      "enchdd1" = "/dev/disk/by-uuid/87f16080-5ff6-43dd-89f3-307455a46fbe";
      "enchdd2" = "/dev/disk/by-uuid/be4a33fa-8bc6-431d-a3ac-787668f223ed";
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
        device = "/dev/disk/by-uuid/87B0-A1D5";
        fsType = "vfat";
      };

      "/home2" = {
        device = "/dev/mapper/enchdd1";
        fsType = "btrfs";
        options = ["compress=lzo" "subvol=@home"];
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

    services.home-assistant = {
      enable = true;
      openFirewall = true;
      configDir = "/var/lib/hass";
      config = {
        homeassistant = {
          name = "SPT";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          time_zone = "Europe/Prague";
          country = "CZ";
        };
        http.server_port = 8808;
        mqtt = {
          broker = config.cynerd.hosts.spt.mox;
          port = 1883;
          username = "homeassistant";
          password = "!secret mqtt_password";
          sensor = import ../modules/home-assistant/sensors.nix;
          light = import ../modules/home-assistant/light.nix;
        };
        met = {};
        default_config = {};
      };
      extraComponents = [];
      package = pkgs.home-assistant.override {
        extraPackages = pkgs:
          with pkgs; [
            securetar
          ];
      };
    };
  };
}
