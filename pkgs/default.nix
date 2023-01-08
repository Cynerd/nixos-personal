{ self, nixpkgs }:

let
  callPackage = nixpkgs.newScope personalpkgs;

  personalpkgs = rec {

    luks-hw-password = callPackage ./luks-hw-password { };
    dev = callPackage ./dev {
      devShells = self.devShells.${nixpkgs.system};
    };

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

    bigclown-leds = callPackage ./bigclown-leds { };

    # Package to be installed to the user's profile
    cynerd-profile = nixpkgs.symlinkJoin {
      name = "cynerd-profile";
      paths = [
        self.inputs.shellrc.packages.${nixpkgs.system}.default
        nixpkgs.tig
      ];
    };

    # Elektroline packages
    shvspy = callPackage ./shvspy { };
    qcoro_task_exception_handling = nixpkgs.libsForQt5.qcoro.overrideAttrs (oldAttrs: {
      version =  "0.6.0";
      src = nixpkgs.fetchFromGitHub {
        owner = "danvratil";
        repo = "qcoro";
        rev = "261663560f59a162c0c82158a6cde41089668871";
        sha256 = "OAYJpoW3b0boSYBfuzLrFvlYSmP3SON8O6HsDQoi+I8=";
      };
    });

  };

in personalpkgs
