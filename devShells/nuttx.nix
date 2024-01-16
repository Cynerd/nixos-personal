pkgs: c: {
  arch,
  fpu ? null,
}:
with builtins;
with pkgs.lib; let
  pkgsCross = import pkgs.path {
    localSystem = pkgs.buildPlatform.system;
    crossSystem = {
      config =
        if (hasPrefix "armv" arch)
        then "arm-none-eabi" + (optionalString (fpu != null) "hf")
        else "riscv32-none-elf";
      libc = "newlib";
      gcc =
        {
          inherit arch;
        }
        // (optionalAttrs (fpu != null) {inherit fpu;});
    };
  };
in
  pkgsCross.buildPackages.mkShell {
    packages = with pkgsCross.buildPackages;
      [
        kconfig-frontends
        genromfs
        xxd
        openocd
        gcc
        gdb
      ]
      ++ (optionals (hasPrefix "rv32" arch) [
        esptool
      ]);
    inputsFrom = [c];
    meta.platforms = pkgsCross.lib.platforms.linux;
  }
