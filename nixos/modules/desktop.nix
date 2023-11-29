{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
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
    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs;
          [
            gnome.dconf-editor
            glib
            gsettings-desktop-schemas
            i3blocks
            sysstat
            wofi
            rofimoji
            wev
            swaybackground
            myswaylock

            alacritty

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

            isync
            msmtp
            notmuch
            astroid
            taskwarrior
            vdirsyncer
            khal
            khard
            gnupg
            pinentry-gnome
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
            youtube-dl
            spotify

            nordic
            delft-icon-theme
            gnome.adwaita-icon-theme
            vanilla-dmz
            sound-theme-freedesktop
            gucharmap

            (sdcv.withDictionaries [stardict-en-cz stardict-de-cz stardict-cz])

            samba
            cifs-utils

            tigervnc
            freerdp
            plasma5Packages.kdeconnect-kde

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
            texlive.combined.scheme-full
            typst
            typst-fmt
            typst-live
            typst-lsp
            vale

            # Gnome utils
            gnome-firmware
            gaphor

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
      vim.package = pkgs.vimHugeX;
      firefox = {
        enable = true;
        languagePacks = ["en-US" "cs"];
        nativeMessagingHosts.packages = with pkgs; [browserpass];
      };
      light.enable = mkIf cnf.laptop true;
    };
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    };
    xdg.mime.defaultApplications = {
      "text/html" = ["firefox.desktop"];
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "image/jpeg" = ["feh.desktop"];
      "image/png" = ["feh.desktop"];
      "image/svg" = ["feh.desktop"];
    };

    programs.usbkey = {
      enable = true;
      devicesUUID = [];
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = true;
    };
    services.dbus.packages = [pkgs.gcr];

    programs.kdeconnect.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    environment.etc."pipewire/pipewire.conf.d/zeroconf.conf".text = ''
      context.modules = [
        { name = libpipewire-module-zeroconf-discover }
      ]
    '';
    security.rtkit.enable = true;

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        cnijfilter2
      ];
    };

    services.avahi.enable = true;
    services.samba-wsdd = {
      enable = true;
      discovery = true;
    };
    networking.firewall.allowedTCPPorts = [5357];
    networking.firewall.allowedUDPPorts = [3702];

    fonts.packages = with pkgs; [
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

    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/scheduler}="bfq"
    '';
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;

    hardware.bluetooth.enable = mkIf cnf.laptop true;

    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };

    documentation = {
      man.enable = true;
      info.enable = true;
    };

    services.snapper.configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_GROUPS = ["users"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
      };
    };

    # Autologin on the first TTY
    services.getty = {
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

    # Leds group is required for light
    users.users.cynerd.extraGroups = ["leds"];

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
    services.xserver.xkbOptions = "grp:alt_shift_toggle,caps:escape";
    services.gpm.enable = true;

    services.locate.enable = true;

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
