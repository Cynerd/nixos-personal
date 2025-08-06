final: prev: {
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

  # OpenWrt One
  armTrustedFirmwareMT7981 = final.callPackage ./mtk-arm-trusted-firmware rec {
    extraMakeFlags = ["BOOT_DEVICE=spim-nand" "DRAM_USE_DDR4=1" "bl2" "bl31"];
    platform = "mt7981";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["build/${platform}/release/bl2.bin" "build/${platform}/release/bl31.bin"];
  };
  ubootOpenWrtOne =
    (final.buildUBoot {
      version = "2025.04";
      src = final.fetchurl {
        url = "https://ftp.denx.de/pub/u-boot/u-boot-2025.04.tar.bz2";
        hash = "sha256-Q5077ylu/9VBML5qcxxbEYvn/d1/zGY8y8X7GClNhxg=";
      };
      defconfig = "mt7981_openwrt-one-spi-nand_defconfig";
      extraMeta.platforms = ["aarch64-linux"];
      BL31 = "${final.armTrustedFirmwareMT7981}/bl31.elf";
      filesToInstall = ["u-boot.bin"];
      extraPatches = [./u-boot-add-openwrt-one.patch];
      extraConfig = ''
        CONFIG_FS_BTRFS=y
        CONFIG_CMD_BTRFS=y
        CONFIG_BOARD_LATE_INIT=n
      '';
    }).overrideAttrs (oldAttrs: {
      nativeBuildInputs = [final.buildPackages.unixtools.xxd] ++ oldAttrs.nativeBuildInputs;
    });

  # nixpkgs patches
  ubootRaspberryPi3_btrfs = prev.buildUBoot {
    defconfig = "rpi_3_defconfig";
    extraConfig = ''
      CONFIG_FS_BTRFS=y
      CONFIG_CMD_BTRFS=y
    '';
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["u-boot.bin"];
  };
  wolfssl = prev.wolfssl.overrideAttrs (oldAttrs: rec {
    version = "5.8.2";
    src = oldAttrs.src.override {
      tag = "v${version}-stable";
      hash = "sha256-rWBfpI6tdpKvQA/XdazBvU5hzyai5PtKRBpM4iplZDU=";
    };
  });
  bind = prev.bind.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [final.buildPackages.protobufc];
    strictDeps = true;
  });

  # Older version of packages
  flac134 = prev.flac.overrideAttrs {
    version = "1.3.4";
    src = final.fetchurl {
      url = "http://downloads.xiph.org/releases/flac/flac-1.3.4.tar.xz";
      hash = "sha256-j/BgfnWjIt181uxI9PIlRxQEricw0OqUUSexNVFV5zc=";
    };
    outputs = ["out"];
  };
}
