{
  config,
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
    openvpn.elektroline = true;
  };

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage"];
  boot.kernelModules = ["kvm-amd"];

  hardware.cpu.amd.updateMicrocode = true;
  services.hardware.openrgb.motherboard = "amd";

  cynerd.autounlock = {
    "encroot" = "/dev/disk/by-uuid/7c412ae6-6016-45af-8c2a-8fcc394dbbe6";
    "enchdd1" = "/dev/disk/by-uuid/87f16080-5ff6-43dd-89f3-307455a46fbe";
    "enchdd2" = "/dev/disk/by-uuid/be4a33fa-8bc6-431d-a3ac-787668f223ed";
    #"encback" = "/dev/disk/by-uuid/1bd8c637-f71e-4fb0-96de-b660c4f1afaf";
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@nix"];
    };
    "/nix" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@nix-store"];
    };
    "/home" = {
      device = "/dev/mapper/encroot";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@home"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/49D9-3A0D";
      fsType = "vfat";
    };

    "/home2" = {
      device = "/dev/mapper/enchdd1";
      fsType = "btrfs";
      options = ["compress=lzo" "subvol=@home"];
    };
    #"/back" = {
    #  device = "/dev/mapper/encback";
    #  fsType = "btrfs";
    #  options = ["compress=lzo"];
    #};
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/" "/home2"];
  };
  #services.beesd.filesystems = {
  #  root = {
  #    spec = "/";
  #    hashTableSizeMB = 4096; # 4KB blocks for 1TB drive
  #    extraOptions = ["--workaround-btrfs-send"];
  #  };
  #  hdd = {
  #    spec = "/home2";
  #    hashTableSizeMB = 8192; # 4KB blocks for 2TB drive
  #    extraOptions = ["--workaround-btrfs-send"];
  #  };
  #};

  networking = {
    useNetworkd = true;
    useDHCP = true;
  };
  systemd.network = {
    wait-online.enable = false;
  };

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

  nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"]; # TODO
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
        sensor = import ../modules/home-assistant/sensors.nix;
        light = import ../modules/home-assistant/light.nix;
      };
      default_config = {};
      automation = "!include automations.yaml";
    };
    extraComponents = ["met"];
    package = pkgs.home-assistant.override {
      extraPackages = pkgs:
        with pkgs; [
          securetar
          pyipp
        ];
    };
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      serial.port = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20220812153849-if00";
      mqtt = {
        server = "mqtt://${config.cynerd.hosts.spt.mox}:1883";
        user = "zigbee2mqtt";
        password = "!secret.yaml mqtt_password";
      };
      advanced = {
        network_key = "!secret.yaml network_key";
        homeassistant_legacy_entity_attributes = false;
        legacy_api = false;
        legacy_availability_payload = false;
        last_seen = "epoch";
      };
      frontend = true;
      availability = true;
      homeassistant = {
        legacy_triggers = false;
      };
      device_options.legacy = false;
      permit_join = false;
      devices = config.secrets.zigbee2mqttDevices;
    };
  };
}
