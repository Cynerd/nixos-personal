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
  astroid = prev.astroid.overrideAttrs (oldAttrs: {
    version = "240629";
    src = final.fetchFromGitHub {
      owner = "astroidmail";
      repo = "astroid";
      rev = "bd0cd0c0a0f1793ced1b3f4e41654cb8cfb32d42";
      hash = "sha256-cQCHWP9kLU6D4op6WMz36ZpzoDKgd+FGbUDuOXoboEQ=";
    };
    patches = [];
    buildInputs = oldAttrs.buildInputs ++ [final.webkitgtk_4_1];
  });

  # nixpkgs patches
  zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs {
    npmInstallFlags = ["--no-optional"]; # Fix cross build
  };
  ubootRaspberryPi3_btrfs = prev.buildUBoot {
    defconfig = "rpi_3_defconfig";
    extraConfig = ''
      CONFIG_FS_BTRFS=y
      CONFIG_CMD_BTRFS=y
    '';
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["u-boot.bin"];
  };

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
