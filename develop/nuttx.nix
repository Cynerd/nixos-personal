{ nixpkgs, shellrc, system }: arch:
let
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-riscv = import nixpkgs.outPath {
    localSystem = system;
    crossSystem = {
      config = "arm-none-eabi";
      libc = "newlib";
      gcc = {
        arch = arch;
      };
    };
  };

in pkgs.mkShell {
  packages = (with pkgs; [
    kconfig-frontends
  ]) ++ (with pkgs-riscv.buildPackages; [
    gcc gdb
  ]);
  inputsFrom = [ shellrc.packages.${system}.default ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
