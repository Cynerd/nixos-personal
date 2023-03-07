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
  #mipsPkgs = import nixpkgs.outPath {
  #  localSystem = system;
  #  crossSystem = {
  #    config = "mips-none-elf";
  #    libc = "newlib-nano";
  #  };
  #};
in
  pkgs.buildPackages.mkShell {
    packages = with pkgs; [
      qtrvsim
      riscvPkgs.buildPackages.gcc
      #mipsPkgs.buildPackages.gcc
    ];
    inputsFrom = [default c];
    meta.platforms = nixpkgs.lib.platforms.linux;
  }
