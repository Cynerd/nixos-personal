{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types;
in {
  options = {
    cynerd.develop = mkOption {
      type = types.bool;
      default = false;
      description = "If machine is about to be used for development.";
    };
  };

  config = mkIf config.cynerd.develop {
    cynerd = {
      devmin = true;
      compile = true;
    };
    environment.systemPackages = with pkgs; [
      # Tools
      git-lfs
      gitlint
      tig
      gitg
      gource
      glab
      github-cli
      wlc # Weblate
      cloc
      openssl
      tio
      vim-vint
      vim-language-server
      vale
      can-utils
      unixtools.xxd

      # Required for neovim plugins
      editorconfig-checker
      go
      gcc

      # Nix
      dev
      cachix
      nurl
      nil
      nixfmt
      alejandra
      statix
      deadnix
      agenix
      nix-tree
      nix-output-monitor

      # Shell
      dash # Posix shell
      bats
      shellcheck
      shfmt
      bash-language-server
      jq
      yq
      fq

      # C
      clang-tools
      bear
      #massif-visualizer
      elf-size-analyze

      # Python
      (python3.withPackages (pypkgs:
        with pypkgs; [
          pip
          ipython
          python-lsp-server

          pytest
          pytest-html
          pytest-tap
          coverage
          mypy

          scipy
          statsmodels
          sympy

          pygraphviz
          matplotlib
          seaborn
          plotly
          pygal

          python-gitlab
          pygithub

          schema
          jinja2
          ruamel-yaml
          msgpack
          urllib3

          influxdb-client
          psycopg
          paho-mqtt

          humanize
          rich

          pygobject3

          pyserial
          pylibftdi
          pyusb
          usbtmc

          pylxd
          selenium

          pyvisa
          pyvisa-py
        ]))
      ruff
      geckodriver
      chromedriver
      # Libraries to be used by python packages
      gobject-introspection
      gtk3
      gtk4

      # Lua
      selene
      stylua

      # Julia
      julia

      # XML
      libxml2

      # Qemmu
      qemu
      virt-manager
      cdrtools

      # Docker
      docker-credential-helpers

      # U-Boot
      ubootTools
      tftp-hpa

      # Network
      iperf3
      inetutils

      # Gtk
      cambalache

      # Barcode generation
      barcode

      # D-Bus
      d-spy

      # Documentation
      man-pages
      man-pages-posix
      linux-manual
      stdmanpages

      # Writing documentation
      docstrfmt

      # SHV
      (shvcli.withPlugins [python3Packages.shvcli-ell])

      # Images
      imagemagick

      # S3
      rclone
    ];
    #programs.wireshark = {
    #  enable = true;
    #  package = pkgs.wireshark;
    #};

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-atk
        cairo
        cups
        dbus
        expat
        gdk-pixbuf
        glib
        gtk3
        libGL
        libXpm
        libdrm
        libgbm
        libgcrypt
        libsoup_3
        libudev0-shim
        libusb1
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        nspr
        nss
        openssl
        pango
        udev
        webkitgtk_4_1
      ];
    };

    documentation = {
      nixos = {
        enable = true;
        includeAllModules = true;
      };
      dev.enable = true;
      doc.enable = true;
    };

    services.guix.enable = true;
    #environment.etc."guix/machines.scm".text = ''
    #  (list (build-machine
    #    (name "czellembsrv.elektroline.cz")
    #    (systems (list "x86_64-linux" "i686-linux"))
    #    (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQZIwdzBo5CvMjS0M9tKYG2ikqPmSgSKRa/UPAoyhBC root@embsrv")
    #    (user "kkoci")
    #    (private-key "/home/cynerd/.ssh/elektroline-emb")
    #    (parallel-builds 16)
    #    (speed 2.0)
    #  ))
    #'';

    virtualisation = {
      containers.enable = true;
      docker = {
        enable = true;
        autoPrune.enable = true;
        storageDriver = "btrfs";
      };
      lxc.enable = true;
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          vhostUserPackages = with pkgs; [virtiofsd];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    networking.firewall.trustedInterfaces = ["virbr0"];

    users.users.cynerd.extraGroups = [
      "docker"
      "lxd"
      "libvirtd"
    ];
  };
}
