nixpkgs: { config, lib, pkgs, ... }:

with lib;

let

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
      tig gource hub github-cli # Git
      wlc # Weblate
      cloc
      openssl
      sterm
      parted

      # Nix
      dev
      nix-prefetch-git nix-prefetch-github nix-prefetch-scripts
      nix-universal-prefetch
      rnix-lsp
      cachix

      # Shell
      dash # Posix shell
      bats
      shellcheck shfmt
      jq yq

      # Python
      (python3.withPackages (pypkgs: with pypkgs; [
        ipython

        pytest pytest-html #pytest-tap
        coverage
        python-lsp-black
        pylint pydocstyle

        mypy

        pygobject3
        pygraphviz matplotlib

        python-gitlab PyGithub

        schema
        jinja2
        ruamel-yaml
        msgpack

        psycopg

        humanize rich
        lorem-text.pythonPackage

        pyserial pylibftdi
        pylxd
        selenium

      ]))
      geckodriver
      chromedriver

      # Lua
      (lua5_1.withPackages  (luapkgs: with luapkgs; [
        luacheck
      ]))

      # Ansible
      ansible

      # Qemmu
      qemu
      virt-manager

      # U-Boot
      #ubootTools
      tftp-hpa

      # Network
      iperf2 iperf3
      wireshark
      inetutils

      # Gtk
      glade

      # Barcode generation
      barcode

      # D-Bus
      dfeet

      # Documentation
      man-pages man-pages-posix linux-manual

      # SHV
      shvspy
    ];
    programs.wireshark.enable = true;

    documentation.dev.enable = true;

    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0660", GROUP="develop", SYMLINK+="stlinkv2_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="a600", ATTRS{idProduct}=="a003", MODE:="0660", GROUP="develop", SYMLINK+="aix_forte_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE:="0660", GROUP="develop", SYMLINK+="jlink_%n"
    '';

    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };
    virtualisation.lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
    virtualisation.lxc.enable = true;
    virtualisation.libvirtd.enable = true;

    users.groups.develop = { };
    users.users.cynerd.extraGroups = [
      "docker" "lxd" "develop" "libvirtd" "wireshark"
    ];

  };

}
