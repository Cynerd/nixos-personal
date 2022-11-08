{ config, lib, pkgs, ... }:

with lib;
let

  cnf = config.cynerd.desktop;

  autologinScript = pkgs.writeText "login-program.sh" ''
    if [[ "$(tty)" == '/dev/tty1' ]]; then
      ${pkgs.shadow}/bin/login -f cynerd;
    else
      ${pkgs.shadow}/bin/login;
    fi
  '';

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
    cynerd.hosts.enable = true;

    programs.sway.enable = true;
    programs.sway.wrapperFeatures.gtk = true;
    programs.sway.extraPackages = with pkgs; [
      gnome.dconf-editor
      glib gsettings-desktop-schemas
      i3blocks sysstat
      wofi rofimoji wev
      swaybackground myswaylock

      alacritty

      kanshi wdisplays wayvnc wl-mirror
      slurp grim
      wf-recorder
      wl-clipboard wl-color-picker
      swayidle
      dunst

      isync msmtp notmuch astroid
      taskwarrior vdirsyncer khal khard
      gnupg pass pinentry-gnome pinentry-curses

      firefox chromium
      ferdium
      libreoffice
      mupdf pdfgrep

      xdg-utils xdg-launch
      mesa-demos vulkan-tools

      pulsemixer
      mpd mpc-cli ncmpcpp
      feh shotwell id3lib
      vlc mpv youtube-dl

      nordic
      delft-icon-theme gnome.adwaita-icon-theme
      vanilla-dmz
      sound-theme-freedesktop
      gucharmap

      (sdcv.withDictionaries [ stardict-en-cz stardict-de-cz stardict-cz ])

      samba cifs-utils

      tigervnc freerdp
      plasma5Packages.kdeconnect-kde

      hdparm ethtool multipath-tools
      usb-modeswitch
      v4l-utils

      # Calculating
      python3Packages.numpy python3Packages.sympy python3Packages.matplotlib

      # Creation
      simple-scan
      audacity
      gimp inkscape
      blender
      kdenlive

      # GStreamer
      gst_all_1.gst-libav
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-plugins-viperfx

      # Latex
      texlive.combined.scheme-full

    ] ++ (optionals cnf.laptop [
      # Power management
      powertop
      acpi
    ]);
    programs.vim.package = pkgs.vimHugeX;
    programs.shellrc.desktop = true;
    xdg.portal.enable = true;
    xdg.portal.wlr.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    xdg.mime.defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "application/pdf" = [ "mupdf.desktop" ];
      "image/jpeg" = [ "feh.desktop" ];
      "image/png" = [ "feh.desktop" ];
      "image/svg" = [ "feh.desktop" ];
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
    services.dbus.packages = [ pkgs.gcr ];

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      config.pipewire = {
        context.modules = [
          { name = "libpipewire-module-zeroconf-discover"; }
        ];
      };
    };
    security.rtkit.enable = true;

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint gutenprintBin
        cnijfilter2
      ];
    };

    services.avahi.enable = true;
    services.samba-wsdd = {
      enable = true;
      discovery = true;
    };
    networking.firewall.allowedTCPPorts = [ 5357 ];
    networking.firewall.allowedUDPPorts = [ 3702 ];

    fonts.fonts = with pkgs; [
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

    documentation.man.man-db.enable = true;

    services.snapper.configs = {
      home = {
        subvolume = "/home";
        extraConfig = ''
          ALLOW_GROUPS="users"
          BACKGROUND_COMPARISON="yes"
          EMPTY_PRE_POST_CLEANUP="yes"
          EMPTY_PRE_POST_MIN_AGE="1800"
          FREE_LIMIT="0.2"
          NUMBER_CLEANUP="yes"
          NUMBER_LIMIT="50"
          NUMBER_LIMIT_IMPORTANT="10"
          NUMBER_MIN_AGE="1800"
          SPACE_LIMIT="0.5"
          TIMELINE_CLEANUP="yes"
          TIMELINE_CREATE="yes"
          TIMELINE_LIMIT_DAILY="10"
          TIMELINE_LIMIT_HOURLY="10"
          TIMELINE_LIMIT_MONTHLY="10"
          TIMELINE_LIMIT_WEEKLY="0"
          TIMELINE_LIMIT_YEARLY="10"
          TIMELINE_MIN_AGE="1800"
        '';
      };
    };

    # Autologin on the first TTY
    services.getty = {
      extraArgs = [ "--skip-login" ];
      loginProgram = "${pkgs.bash}/bin/sh";
      loginOptions = toString (pkgs.writeText "login-program.sh" ''
        if [[ "$(tty)" == '/dev/tty1' ]]; then
          ${pkgs.shadow}/bin/login -f cynerd;
        else
          ${pkgs.shadow}/bin/login;
        fi
      '');
    };

    # VTI settings
    console = {
      colors = [
        "2e3440" "3b4252" "434c5e" "4c566a" "d8dee9" "e5e9f0" "eceff4" "8fbcbb"
        "88c0d0" "81a1c1" "5e81ac" "bf616a" "d08770" "ebcb8b" "a3be8c" "b48ead"
      ];
      earlySetup = true;
      useXkbConfig = true;
    };
    services.xserver.xkbOptions = "grp:alt_shift_toggle,caps:escape";
    services.gpm.enable = true;

    services.locate.enable = true;

  };
}
