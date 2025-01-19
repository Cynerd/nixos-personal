{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkMerge mkIf;

  configTxt = pkgs.writeText "config.txt" ''
    [pi3]
    kernel=u-boot-rpi3.bin

    # Boot in 64-bit mode.
    arm_64bit=1

    # Otherwise the serial output will be garbled.
    core_freq=250
    # Boot in 64-bit mode.
    arm_64bit=1

    [all]
    # U-Boot needs this to work, regardless of whether UART is actually used or not.
    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
    # a requirement in the future.
    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    avoid_warnings=1
  '';
in {
  options.cynerd.rpi = mkOption {
    type = with types; nullOr (enum [2 3]);
    default = null;
    description = "If machine is RaspberryPi and which version";
  };

  config = mkMerge [
    (mkIf (config.cynerd.rpi == 2) {
      nixpkgs.hostPlatform.system = "armv7l-linux";
    })
    (mkIf (config.cynerd.rpi == 3) {
      nixpkgs.hostPlatform.system = "aarch64-linux";
      boot.kernelParams = ["console=ttyS1,115200n8"];
    })
    (mkIf (config.cynerd.rpi != null) {
      boot.loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
        generic-extlinux-compatible.enable = true;
      };
      boot.consoleLogLevel = 7;

      fileSystems = {
        "/" = {
          device = "/dev/mmcblk0p2";
          fsType = "ext4";
        };
        #"/" = {
        #  device = "/dev/mmcblk0p2";
        #  fsType = "btrfs";
        #  options = ["compress=lzo"];
        #};
        "/boot/firmware" = {
          device = "/dev/mmcblk0p1";
          fsType = "vfat";
          options = ["nofail"];
        };
      };

      services.journald.extraConfig = ''
        SystemMaxUse=512M
      '';

      system.build.firmware = pkgs.callPackage ({stdenvNoCC}:
        stdenvNoCC.mkDerivation {
          name = "${config.system.name}-firmware";
          buildCommand = ''
            mkdir $out
            cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/* $out/
            cp ${configTxt} $out/config.txt
            # TODO support rpi2
            cp ${pkgs.ubootRaspberryPi3_btrfs}/u-boot.bin $out/u-boot-rpi3.bin
          '';
        }) {};
    })
  ];
}
