nixpkgs: { config, lib, pkgs, ... }:

with lib;

let

  armv6l = (import nixpkgs.outPath {
      localSystem = config.system.build.toplevel.system;
      crossSystem = {
        config = "armv6l-none-eabi";
        libc = "newlib";
      };
    });
  armv7l = (import nixpkgs.outPath {
      localSystem = config.system.build.toplevel.system;
      crossSystem = {
        config = "armv7l-none-eabi";
        libc = "newlib";
      };
    });

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
      #armv6l.buildPackages.gcc armv6l.buildPackages.gdb
      #armv7l.buildPackages.gcc armv7l.buildPackages.gdb
      pkgsCross.arm-embedded.buildPackages.gcc

    ];

  };

}
