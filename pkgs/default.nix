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

    # Nixpkgs fixes
    khal = pkgs.khal.overrideAttrs (oldAttrs: {
      disabledTests =
        pkgs.lib.warnIf (oldAttrs.version != "0.10.5") "Khal is updated. Check if override is still required."
        oldAttrs.disabledTests
        ++ [
          "test__construct_event_format_de_complexer"
          "test__construct_event_format_us"
          "test_alarm"
          "test_berlin"
          "test_berlin_rdate"
          "test_construct_event_format_de"
          "test_construct_event_format_de_complexer"
          "test_construct_event_format_us"
          "test_create_timezone_in_future"
          "test_create_timezone_static"
          "test_description"
          "test_dt_two_tz"
          "test_get"
          "test_leap_year"
          "test_raw_dt"
          "test_repeat_floating"
          "test_repeat_localized"
          "test_split_ics"
          "test_split_ics_random_uid"
          "test_transform_event"
        ];
    });
  };
in
  personalpkgs
