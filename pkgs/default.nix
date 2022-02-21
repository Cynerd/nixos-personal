{ nixpkgs ? <nixpkgs>, nixlib ? nixpkgs.lib }:

let
  pkgs = nixpkgs // personalpkgs;
  callPackage = nixlib.callPackageWith pkgs;

  personalpkgs = with pkgs; {

    wireplumber = nixpkgs.wireplumber.overrideAttrs (oldAttrs: {
      patches = [
        ./patches/0001-wpctl-Add-get-volume-command-and-functionality.patch
        ./patches/0002-wpctl-allow-modifying-volume-levels-using-percentage.patch
      ];
    });

    delft-icon-theme = callPackage ./theme/delft-icon-theme.nix { };
    background-lnxpcs = callPackage ./theme/background-lnxpcs.nix { };
    swaybackground = callPackage ./theme/swaybackground.nix { };
    myswaylock = callPackage ./theme/myswaylock.nix { };

    #personalPython3Packages = python3.withPackages (pythonPackages:
    #with pythonPackages; [
    #  (pythonPackages.callPackage ./python/notify-send.nix { })
    #]);

  };

in personalpkgs
