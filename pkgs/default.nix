final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [(import ./python.nix)];

  luks-hw-password = final.callPackage ./luks-hw-password {};
  dev = final.callPackage ./dev {
    devShells = import ../devShells final;
  };

  background-lnxpcs = final.callPackage ./theme/background-lnxpcs.nix {};
  swaybackground = final.callPackage ./theme/swaybackground.nix {};
  myswaylock = final.callPackage ./theme/myswaylock.nix {};

  stardict-unwrapped = final.callPackage ./stardict {};
  stardict = final.callPackage ./stardict/wrapper.nix {stardict = final.stardict-unwrapped;};
  stardict-en-cz = final.callPackage ./stardict/en-cz.nix {};
  stardict-de-cz = final.callPackage ./stardict/de-cz.nix {};
  stardict-cz = final.callPackage ./stardict/cz.nix {};
  sdcv-unwrapped = prev.sdcv;
  sdcv = final.callPackage ./stardict/wrapper.nix {stardict = final.sdcv-unwrapped;};

  lorem-text = final.callPackage ./lorem-text {};

  bigclown-leds = final.callPackage ./bigclown-leds {};

  dodo = final.callPackage ./dodo {};
  elf-size-analyze = final.callPackage ./elf-size-analyze {};

  # OpenWrt One
  armTrustedFirmwareMT7981 = final.callPackage ./mtk-arm-trusted-firmware rec {
    extraMakeFlags = [
      "BOOT_DEVICE=spim-nand"
      "DRAM_USE_DDR4=1"
      "UBI=1"
      "OVERRIDE_UBI_START_ADDR=0x100000"
      "bl2"
      "bl31"
    ];
    platform = "mt7981";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["build/${platform}/release/bl2.bin" "build/${platform}/release/bl31.bin"];
  };
  ubootOpenWrtOne =
    # ubiupdatevol /dev/ubi0_2 u-boot.fip
    (final.buildUBoot {
      defconfig = "mt7981_openwrt-one-spi-nand_defconfig";
      extraMeta.platforms = ["aarch64-linux"];
      filesToInstall = ["u-boot.fip" ".config"];
      extraPatches = [./u-boot-add-openwrt-one.patch];
      extraConfig = ''
        CONFIG_CMD_BOOTMENU=n
        CONFIG_AUTOBOOT_MENU_SHOW=n
        CONFIG_BOOTDELAY=3

        CONFIG_PCI=y
        CONFIG_PCIE_MEDIATEK_GEN3=y
        CONFIG_PCI_DEBUG=y
        CONFIG_DM_REGULATOR=y
        CONFIG_NVME=y
        CONFIG_NVME_PCI=y
        CONFIG_CMD_NVME=y
        CONFIG_EFI_PARTITION=y

        CONFIG_CMD_SYSBOOT=y
        CONFIG_SUPPORT_RAW_INITRD=y

        CONFIG_BOARD_LATE_INIT=n
      '';
      postBuild = ''
        ${final.buildPackages.armTrustedFirmwareTools}/bin/fiptool create \
          --soc-fw '${final.armTrustedFirmwareMT7981}/bl31.bin' \
          --nt-fw ./u-boot.bin \
          u-boot.fip
      '';
    }).overrideAttrs (oldAttrs: {
      nativeBuildInputs = [final.buildPackages.unixtools.xxd] ++ oldAttrs.nativeBuildInputs;
    });

  # RaspberryPi
  ubootRaspberryPi3_btrfs = prev.buildUBoot {
    defconfig = "rpi_3_defconfig";
    extraConfig = ''
      CONFIG_FS_BTRFS=y
      CONFIG_CMD_BTRFS=y
    '';
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  # NixPkgs patches
  xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (oldAttrs: {
    patches =
      oldAttrs.patches
      ++ [
        # https://github.com/NixOS/nixpkgs/pull/548762
        (final.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/raw/4ba561388760a6fdfe376cbef28613b4366161ab/pkgs/by-name/xd/xdg-desktop-portal/allow-no-graphical-session-target.patch";
          hash = "sha256-55RFYk4Fzsj8xp6j0wg1AEz+9c05tqfNkPCP+z9czdI=";
        })
      ];
  });
  #gnutls =
  #  if prev.stdenv.hostPlatform != prev.stdenv.buildPlatform
  #  then
  #    prev.gnutls.overrideAttrs (oldAttrs: {
  #      configureFlags = oldAttrs.configureFlags ++ ["--disable-doc"];
  #      outputs = builtins.filter (v: v != "man" && v != "devdoc") oldAttrs.outputs;
  #    })
  #  else prev.gnutls;
  #git =
  #  if prev.stdenv.hostPlatform != prev.stdenv.buildPlatform
  #  then prev.git.override {rustSupport = false;}
  #  else prev.git;
  gvproxy =
    if prev.stdenv.hostPlatform.is32bit
    then
      # Downgrade to get 32bit support working
      prev.gvproxy.overrideAttrs (oldAttrs: {
        version = "0.8.6";
        src = oldAttrs.src.override {
          rev = "v0.8.6";
          hash = "sha256-a/Gd1QUxZ+47sQtndbehx86UjC1DezhqwS5d5VTIjRc=";
        };
      })
    else prev.gvproxy;

  # Older version of packages
  flac134 = prev.flac.overrideAttrs {
    version = "1.3.4";
    src = final.fetchurl {
      url = "http://downloads.xiph.org/releases/flac/flac-1.3.4.tar.xz";
      hash = "sha256-j/BgfnWjIt181uxI9PIlRxQEricw0OqUUSexNVFV5zc=";
    };
    outputs = ["out"];
    doCheck = false;
  };
}
