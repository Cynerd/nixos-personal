{ system, nixpkgs
, default, c
}:
let
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-riscv = import nixpkgs.outPath {
    localSystem = system;
    crossSystem = {
      config = "riscv32-none-elf";
      libc = "newlib";
      gcc = {
        arch = "rv32i";
      };
    };
  };

in pkgs.mkShell {
  packages = (with pkgs; [
    qtrvsim
  ]) ++ (with pkgs-riscv.buildPackages; [
    gcc pkg-config
  ]);
  inputsFrom = [ default c ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
