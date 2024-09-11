{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types optionals;
  cnf = config.cynerd.desktop;
in {
  options = {
    cynerd.desktop = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable my desktop";
      };
      laptop = mkOption {
        type = types.bool;
        default = false;
        description = "The desktop requires Laptop extensions";
      };
    };
  };

  config = mkIf cnf.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      bluetooth.enable = mkIf cnf.laptop true;
    };

    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs;
          [
            dconf-editor
            glib
            gsettings-desktop-schemas
            sysstat
            wofi
            rofimoji
            wev
            waybar
            swaybackground
            myswaylock

            alacritty
            nautilus

            kanshi
            wdisplays
            wayvnc
            wl-mirror
            slurp
            grim
            wf-recorder
            wl-clipboard
            wl-color-picker
            swayidle
            dunst
            libnotify

            resources

            isync
            msmtp
            notmuch
            astroid
            taskwarrior3
            vdirsyncer
            khal
            khard
            gnupg
            pinentry-gnome3
            pinentry-curses
            (pass.withExtensions (exts: [
              exts.pass-otp
              exts.pass-audit
            ]))

            chromium
            ferdium
            signal-desktop
            libreoffice
            mupdf
            zathura
            pdfgrep

            xdg-utils
            xdg-launch
            mesa-demos
            vulkan-tools

            pulsemixer
            mpd
            mpc-cli
            ncmpcpp
            feh
            shotwell
            id3lib
            vlc
            mpv
            yt-dlp
            spotify

            nordic
            nordzy-cursor-theme
            nordzy-icon-theme
            adwaita-icon-theme
            vanilla-dmz
            sound-theme-freedesktop
            gnome-characters
            gucharmap

            (sdcv.withDictionaries [stardict-en-cz stardict-de-cz stardict-cz])

            samba
            cifs-utils

            tigervnc
            freerdp
            plasma5Packages.kdeconnect-kde

            gnome-firmware
            hdparm
            ethtool
            multipath-tools
            usb-modeswitch
            v4l-utils

            # Calculating
            python3Packages.numpy
            python3Packages.sympy
            python3Packages.matplotlib

            # Creation
            simple-scan
            audacity
            gimp
            inkscape
            blender
            kdenlive

            # GStreamer
            gst_all_1.gst-libav
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            gst_all_1.gst-plugins-ugly
            gst_all_1.gst-plugins-viperfx

            # Writing
            typst
            typst-fmt
            typst-live
            typst-lsp
            vale

            # CAD
            freecad
            kicad
            sweethome3d.application
            qelectrotech
          ]
          ++ (optionals cnf.laptop [
            # Power management
            powertop
            acpi
          ]);
      };

      firefox = {
        enable = true;
        languagePacks = ["en-US" "cs"];
        nativeMessagingHosts.packages = with pkgs; [browserpass];
      };

      light.enable = mkIf cnf.laptop true;

      nix-ld = {
        enable = true;
        libraries = with pkgs; [xorg.libXpm];
      };

      usbkey = {
        enable = true;
        devicesUUID = [
          "de269652-2070-46b2-84f8-409dc9dd50ee"
          "16a089d0-a663-4047-bd88-3885dd7fdee2"
        ];
      };

      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        enableBrowserSocket = true;
      };
    };

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      };
      mime.defaultApplications = {
        "text/html" = ["firefox.desktop"];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "image/jpeg" = ["feh.desktop"];
        "image/png" = ["feh.desktop"];
        "image/svg" = ["feh.desktop"];
      };
    };

    services = {
      # Autologin on the first TTY
      getty = {
        extraArgs = ["--skip-login"];
        loginProgram = "${pkgs.bash}/bin/sh";
        loginOptions = toString (pkgs.writeText "login-program.sh" ''
          if [[ "$(tty)" == '/dev/tty1' ]]; then
            ${pkgs.shadow}/bin/login -f cynerd;
          else
            ${pkgs.shadow}/bin/login;
          fi
        '');
      };

      gpm.enable = true; # mouse in buffer
      udev.extraRules = ''
        ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/scheduler}="bfq"
      '';
      xserver.xkb.options = "grp:alt_shift_toggle,caps:escape";

      # Gnome crypto services (GnuPG)
      dbus.packages = [pkgs.gcr];

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        extraConfig.pipewire."10-zeroconf" = {
          "context.modules" = [{name = "libpipewire-module-zeroconf-discover";}];
        };
      };

      upower.enable = true;
      hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
      };

      printing = {
        enable = true;
        drivers = with pkgs; [
          gutenprint
          gutenprintBin
          cnijfilter2
        ];
      };
      avahi.enable = true;
      samba-wsdd = {
        enable = true;
        discovery = true;
      };
      davfs2.enable = true;

      locate.enable = true;
    };

    # Beneficial for Pipewire
    security.rtkit.enable = true;

    # Local share (avahi, samba)
    networking.firewall = {
      allowedTCPPorts = [5357];
      allowedUDPPorts = [3702];
    };

    fonts.packages = with pkgs; [
      (nerdfonts.override {fonts = ["Hack"];})
      arkpandora_ttf
      corefonts
      dejavu_fonts
      font-awesome
      freefont_ttf
      hack-font
      liberation_ttf
      libertine
      noto-fonts
      noto-fonts-emoji
      terminus_font_ttf
      ubuntu_font_family
      unifont
    ];

    documentation = {
      enable = true;
      man.enable = true;
      info.enable = true;
    };

    # VTI settings
    console = {
      colors = [
        "2e3440"
        "3b4252"
        "434c5e"
        "4c566a"
        "d8dee9"
        "e5e9f0"
        "eceff4"
        "8fbcbb"
        "88c0d0"
        "81a1c1"
        "5e81ac"
        "bf616a"
        "d08770"
        "ebcb8b"
        "a3be8c"
        "b48ead"
      ];
      earlySetup = true;
      useXkbConfig = true;
    };

    # Support running app images
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
