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
    cynerd.compile = true;
    environment.enableDebugInfo = true;
    environment.systemPackages = with pkgs; [
      # Tools
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
      nodePackages.vim-language-server
      vale

      # Required for neovim plugins
      editorconfig-checker
      go
      gcc

      # Nix
      dev
      cachix
      nurl
      nil
      nixfmt-rfc-style
      alejandra
      statix
      deadnix
      agenix
      nix-tree

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
      massif-visualizer
      qcachegrind

      # Python
      (python3.withPackages (pypkgs:
        with pypkgs; [
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
          PyGithub

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

      # SHV
      (shvcli.withPlugins [python3Packages.shvcli-ell])

      # Images
      imagemagick
    ];
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    documentation = {
      nixos = {
        enable = true;
        includeAllModules = true;
      };
      dev.enable = true;
      doc.enable = true;
    };

    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0660", GROUP="develop", SYMLINK+="stlinkv2_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="a600", ATTRS{idProduct}=="a003", MODE:="0660", GROUP="develop", SYMLINK+="aix_forte_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE:="0660", GROUP="develop", SYMLINK+="jlink_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2111", MODE:="0660", GROUP="develop", SYMLINK+="cmsip_dap_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1ab1", ATTRS{idProduct}=="0e11", MODE:="0660", GROUP="develop"
    '';

    virtualisation = {
      containers.enable = true;
      docker = {
        enable = true;
        autoPrune.enable = true;
        storageDriver = "btrfs";
      };
      lxd = {
        enable = true;
        recommendedSysctlSettings = true;
      };
      lxc.enable = true;
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };

    users.groups.develop = {};
    users.users.cynerd.extraGroups = [
      "docker"
      "lxd"
      "develop"
      "libvirtd"
    ];
  };
}
