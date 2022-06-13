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
    environment.systemPackages = with pkgs; [
      # Tools
      tig gource hub github-cli # Git
      wlc # Weblate
      cloc
      openssl
      sterm

      # Nix
      nix-prefetch-git nix-prefetch-github nix-prefetch-scripts

      # C
      ccls bear
      check
      valgrind
      cppcheck flawfinder
      gdb
      lcov massif-visualizer

      # Shell
      dash # Posix shell
      bats
      shellcheck

      # Python
      python3 python3Packages.ipython
      twine
      python3Packages.pytest python3Packages.pytest-html #python3Packages.pytest-tap
      python3Packages.coverage
      python3Packages.python-lsp-black
      mypy
      pylint python3Packages.pydocstyle

      # Lua
      lua51Packages.luacheck

      # Ansible
      ansible

      # U-Boot
      ubootTools
      tftp-hpa

      # Network
      iperf2 iperf3
      wireshark
      inetutils

      # Gtk
      glade

      # Containers
      lxc lxd
      docker

      # Barcode generation
      barcode

      # D-Bus
      dfeet

      # Bare metal
      openocd

      # Documentation
      man-pages man-pages-posix
    ];

    documentation.dev.enable = true;

  };

}
