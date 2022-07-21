{ system, nixpkgs, default }:
{ arch, fpu ? null }:
with nixpkgs.lib;
let
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-riscv = import nixpkgs.outPath {
    localSystem = system;
    crossSystem = {
      config = "arm-none-eabi" + (optionalString (fpu != null) "hf");
      libc = "newlib";
      gcc = {
        arch = arch;
      } // (optionalAttrs (fpu != null) { fpu = fpu; });
    };
  };

in pkgs.mkShell {
  packages = (with pkgs; [
    gnumake
    kconfig-frontends genromfs xxd
    openocd
  ]) ++ (with pkgs-riscv.buildPackages; [
    gcc gdb
  ]);
  inputsFrom = [ default ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
