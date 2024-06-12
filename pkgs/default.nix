final: prev: let
  inherit (final.lib) optional;
  is_cross = final.buildPlatform != final.targetPlatform;
in {
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
  sdcv-unwrapped = final.callPackage ./sdcv {};
  sdcv = final.callPackage ./stardict/wrapper.nix {stardict = final.sdcv-unwrapped;};

  lorem-text = final.callPackage ./lorem-text {};

  bigclown-leds = final.callPackage ./bigclown-leds {};

  # nixpkgs patches
  #zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs (oldAttrs: {
  #  npmInstallFlags = ["--no-optional"]; # Fix cross build
  #});
  flac1_3 = prev.flac.overrideAttrs {
    version = "1.3.4";
    src = final.fetchurl {
      url = "http://downloads.xiph.org/releases/flac/flac-1.3.4.tar.xz";
      hash = "sha256-j/BgfnWjIt181uxI9PIlRxQEricw0OqUUSexNVFV5zc=";
    };
    outputs = ["out"];
  };
  gnupg = prev.gnupg.overrideAttrs (oldAttrs: {
    nativeBuildInputs =
      oldAttrs.nativeBuildInputs
      ++ (optional is_cross prev.libgpg-error);
  });
  mastroid = prev.astroid.overrideAttrs (oldAttrs: {
    src = final.fetchFromGitHub {
      owner = "astroidmail";
      repo = "astroid";
      rev = "c1e5cdbd662e2bcfef2fe5dc72dbc444a692a0e8";
      sha256 = "sha256-aLxVA9gW4dzRMqgaPsP5slfYl8fz/lKHRzl+NnkH60s=";
    };
    patches = [];
  });
}
