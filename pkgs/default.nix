final: prev: let
  # The NodeJS packages has to be build in 32bit environment if host platform is
  # also 32bit because it uses 32bit stubs and links against 32bit OpenSSL. The
  # only architecture that generally supports execution of 32bit is x86_64 and
  # thus that is the only one handled here.
  callPackageNodejs =
    if prev.stdenv.buildPlatform.isx86_64 && prev.stdenv.is32bit
    then prev.buildPackages.pkgsi686Linux.callPackage
    else prev.callPackage;
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
  zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs (oldAttrs: {
    npmInstallFlags = ["--no-optional"]; # Fix cross build
  });
  nodejs_18 = callPackageNodejs (prev.path + "/pkgs/development/web/nodejs/v18.nix") {};
  nodejs-slim_18 = callPackageNodejs (prev.path + "/pkgs/development/web/nodejs/v18.nix") {enableNpm = false;};
  nodejs_20 = callPackageNodejs (prev.path + "/pkgs/development/web/nodejs/v20.nix") {};
  nodejs-slim_20 = callPackageNodejs (prev.path + "/pkgs/development/web/nodejs/v20.nix") {enableNpm = false;};
  nodejs_22 = callPackageNodejs (prev.path + "/pkgs/development/web/nodejs/v22.nix") {};
  nodejs-slim_22 = callPackageNodejs (prev.path + "/pkgs/development/web/nodejs/v22.nix") {enableNpm = false;};
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (
        pyfinal: pyprev: {
          bcg = pyprev.bcg.overrideAttrs {
            patches =
              pyprev.bcg.patches
              ++ [
                (final.fetchpatch2 {
                  name = "bcg-fix-import-with-Python-3.12.patch";
                  url = "https://github.com/cynerd/bch-gateway/commit/1314c892992d8914802b6c42602c39f6a1418fca.patch";
                  hash = "sha256-+vmkqnnkf81umjesTIFgh0mMh2fCCn/yFyQl6ENP9Cc=";
                })
              ];
            propagatedBuildInputs =
              pyprev.bcg.propagatedBuildInputs
              ++ [pyfinal.looseversion];
          };
        }
      )
    ];

  # Older version of packages
  flac1_3 = prev.flac.overrideAttrs {
    version = "1.3.4";
    src = final.fetchurl {
      url = "http://downloads.xiph.org/releases/flac/flac-1.3.4.tar.xz";
      hash = "sha256-j/BgfnWjIt181uxI9PIlRxQEricw0OqUUSexNVFV5zc=";
    };
    outputs = ["out"];
  };
}
