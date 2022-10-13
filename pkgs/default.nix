{ self, nixpkgs }:

let
  pkgs = nixpkgs // personalpkgs;
  callPackage = nixpkgs.lib.callPackageWith pkgs;

  personalpkgs = with pkgs; {

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

    # Package to be installed to the user's profile
    cynerd-profile = pkgs.symlinkJoin {
      name = "cynerd-profile";
      paths = with pkgs; [
        self.inputs.shellrc.packages.${nixpkgs.system}.default
        tig
      ];
    };

  };

in personalpkgs
