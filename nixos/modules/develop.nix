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
      gource
      hub
      github-cli # Git
      wlc # Weblate
      cloc
      openssl
      tio
      vim-vint
      nodePackages.vim-language-server
      ctags

      # Nix
      dev
      cachix
      nurl
      nix-universal-prefetch
      rnix-lsp
      nixd
      alejandra
      statix
      deadnix
      agenix

      # Shell
      dash # Posix shell
      bats
      shellcheck
      shfmt
      jq
      yq
      fq

      # Python
      (python3.withPackages (pypkgs:
        with pypkgs; [
          ipython

          pytest
          pytest-html
          pytest-tap
          coverage
          python-lsp-black
          pylint
          pydocstyle
          mypy

          pygraphviz
          matplotlib

          python-gitlab
          PyGithub
        ]))
      geckodriver
      chromedriver

      # Julia
      julia

      # Qemmu
      qemu
      virt-manager
      cdrtools

      # U-Boot
      ubootTools
      tftp-hpa

      # Network
      iperf3
      wireshark
      inetutils

      # Gtk
      cambalache

      # Barcode generation
      barcode

      # D-Bus
      dfeet

      # Documentation
      man-pages
      man-pages-posix
      linux-manual
      stdmanpages

      # SHV
      shvspy
      flatline
      shvcli

      # Images
      imagemagick
    ];
    programs.wireshark.enable = true;

    documentation = {
      dev.enable = true;
      doc.enable = true;
    };

    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0660", GROUP="develop", SYMLINK+="stlinkv2_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="a600", ATTRS{idProduct}=="a003", MODE:="0660", GROUP="develop", SYMLINK+="aix_forte_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE:="0660", GROUP="develop", SYMLINK+="jlink_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2111", MODE:="0660", GROUP="develop", SYMLINK+="cmsip_dap_%n"
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
      "wireshark"
    ];
  };
}
