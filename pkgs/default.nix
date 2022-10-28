{ self, nixpkgs }:

let
  callPackage = nixpkgs.newScope personalpkgs;

  personalpkgs = rec {

    luks-hw-password = callPackage ./luks-hw-password { };

    delft-icon-theme = callPackage ./theme/delft-icon-theme.nix { };
    background-lnxpcs = callPackage ./theme/background-lnxpcs.nix { };
    swaybackground = callPackage ./theme/swaybackground.nix { };
    myswaylock = callPackage ./theme/myswaylock.nix { };

    stardict-unwrapped = callPackage ./stardict { };
    stardict = callPackage ./stardict/wrapper.nix { stardict = stardict-unwrapped; };
    stardict-en-cz = callPackage ./stardict/en-cz.nix { };
    stardict-de-cz = callPackage ./stardict/de-cz.nix { };
    stardict-cz = callPackage ./stardict/cz.nix { };
    sdcv-unwrapped = callPackage ./sdcv { };
    sdcv = callPackage ./stardict/wrapper.nix { stardict = sdcv-unwrapped; };

    lorem-text = callPackage ./lorem-text { };

    # Package to be installed to the user's profile
    cynerd-profile = nixpkgs.symlinkJoin {
      name = "cynerd-profile";
      paths = [
        self.inputs.shellrc.packages.${nixpkgs.system}.default
        nixpkgs.tig
      ];
    };

    # cyrus_sasl with curus_sasl_xoauth2
    cyrus_sasl_xoauth2 = callPackage ./cyrus-sasl-xoauth2 {
      cyrus_sasl = nixpkgs.cyrus_sasl; # prevent infinite cycle
    };
    cyrus_sasl = nixpkgs.cyrus_sasl.overrideAttrs (div: rec {
      postInstall = ''
        for lib in ${cyrus_sasl_xoauth2}/usr/lib/sasl2/*; do
          ln -sf $lib $out/lib/sasl2/
        done
      '';
    });

  };

in personalpkgs
