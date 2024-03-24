{lib, ...}: let
  inherit (lib) mkDefault;
in {
  nixpkgs.hostPlatform.system = "x86_64-linux";
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
    wireguard = true;
    openvpn.elektroline = true;
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

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    networks = {
      "dhcp" = {
        matchConfig.Name = "enp2s0f0 enp5s0f3u1u1 wlp3s0";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
    wait-online.enable = false;
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
