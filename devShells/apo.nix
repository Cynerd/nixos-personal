{
  pkgs,
  default,
  c,
}: let
  riscvPkgs = import pkgs.path {
    localSystem = pkgs.buildPlatform.system;
    crossSystem = {
      config = "riscv32-none-elf";
      libc = "newlib-nano";
      gcc = {
        arch = "rv32i";
      };
    };
  };
in
  pkgs.buildPackages.mkShell {
    packages = with pkgs; [
      qtrvsim
      glibc.static
      riscvPkgs.buildPackages.gcc
    ];
    inputsFrom = [default c];
    meta.platforms = pkgs.lib.platforms.linux;
  }
