pkgs: c: let
  riscvPkgs = import pkgs.path {
    localSystem = pkgs.buildPlatform.system;
    crossSystem = {
      config = "riscv32-none-elf";
      libc = "newlib";
      gcc.arch = "rv32i";
    };
  };
in
  pkgs.buildPackages.mkShell {
    packages = with pkgs; [
      qtrvsim
      glibc.static
      riscvPkgs.buildPackages.gcc
    ];
    inputsFrom = [c];
    meta.platforms = pkgs.lib.platforms.linux;
  }
