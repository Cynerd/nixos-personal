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
      config = if (hasPrefix "armv" arch) then
        "arm-none-eabi" + (optionalString (fpu != null) "hf")
        else "riscv32-none-elf";
      libc = "newlib-nano";
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
  ] ++ (optionals (hasPrefix "rv32" arch) [
    esptool
  ]);
  inputsFrom = [ default c ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
