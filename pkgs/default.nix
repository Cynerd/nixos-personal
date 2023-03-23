pkgs: let
  callPackage = pkgs.newScope personalpkgs;

  personalpkgs = rec {
    luks-hw-password = callPackage ./luks-hw-password {};
    dev = callPackage ./dev {
      devShells = import ../devShells pkgs;
    };

    delft-icon-theme = callPackage ./theme/delft-icon-theme.nix {};
    background-lnxpcs = callPackage ./theme/background-lnxpcs.nix {};
    swaybackground = callPackage ./theme/swaybackground.nix {};
    myswaylock = callPackage ./theme/myswaylock.nix {};

    stardict-unwrapped = callPackage ./stardict {};
    stardict = callPackage ./stardict/wrapper.nix {stardict = stardict-unwrapped;};
    stardict-en-cz = callPackage ./stardict/en-cz.nix {};
    stardict-de-cz = callPackage ./stardict/de-cz.nix {};
    stardict-cz = callPackage ./stardict/cz.nix {};
    sdcv-unwrapped = callPackage ./sdcv {};
    sdcv = callPackage ./stardict/wrapper.nix {stardict = sdcv-unwrapped;};

    lorem-text = callPackage ./lorem-text {};

    bigclown-leds = callPackage ./bigclown-leds {};

    # Elektroline packages
    shvspy = callPackage ./shvspy {};
  };
in
  personalpkgs
