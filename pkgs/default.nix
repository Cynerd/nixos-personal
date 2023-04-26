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

    # cyrus_sasl with curus_sasl_xoauth2
    cyrus_sasl_xoauth2 = callPackage ./cyrus-sasl-xoauth2 {
      inherit (pkgs) cyrus_sasl;
    };
    cyrus_sasl = pkgs.cyrus_sasl.overrideAttrs (div: rec {
      postInstall = ''
        for lib in ${cyrus_sasl_xoauth2}/usr/lib/sasl2/*; do
          ln -sf $lib $out/lib/sasl2/
        done
      '';
    });
  };
in
  personalpkgs
