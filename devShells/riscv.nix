{
  system,
  nixpkgs,
  default,
  c,
}: let
  pkgs = import nixpkgs.outPath {
    localSystem = system;
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
    packages = with pkgs.buildPackages; [
      qtrvsim
      gcc
      pkg-config
    ];
    inputsFrom = [default c];
    meta.platforms = nixpkgs.lib.platforms.linux;
  }
