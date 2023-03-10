{
  system,
  nixpkgs,
  default,
  c,
}: let
  pkgs = nixpkgs.legacyPackages.${system};
  riscvPkgs = import nixpkgs.outPath {
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
    packages = with pkgs; [
      qtrvsim
      glibc.static
      riscvPkgs.buildPackages.gcc
    ];
    inputsFrom = [default c];
    meta.platforms = nixpkgs.lib.platforms.linux;
  }
