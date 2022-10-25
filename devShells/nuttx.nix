{ system, nixpkgs
, default, c
, arch, fpu ? null
}:
with builtins;
with nixpkgs.lib;
let
  pkgs = import nixpkgs.outPath {
    localSystem = system;
    crossSystem = {
      config = if (match "armv.*" arch != null) then
        "arm-none-eabi" + (optionalString (fpu != null) "hf")
        else "riscv32-none-elf";
      libc = "newlib";
      gcc = {
        arch = arch;
      } // (optionalAttrs (fpu != null) { fpu = fpu; });
    };
  };

in pkgs.buildPackages.mkShell {
  packages = with pkgs.buildPackages; [
    kconfig-frontends genromfs xxd
    openocd
    gcc gdb
  ] ++ (optionals (match "rv32.*" arch != null) [
    esptool
  ]);
  inputsFrom = [ default c ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
