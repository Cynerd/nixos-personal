{ nixpkgs ? <nixpkgs>, nixlib ? nixpkgs.lib }:

let
  pkgs = nixpkgs // personalpkgs;
  callPackage = nixlib.callPackageWith pkgs;

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

    ferdium = callPackage ./ferdium {
      mkFranzDerivation = callPackage (
        nixpkgs.path + "/pkgs/applications/networking/instant-messengers/franz/generic.nix"
      ) { };
    };

  };

in personalpkgs
