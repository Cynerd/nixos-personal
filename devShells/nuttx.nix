{ system, nixpkgs
, default, c
, arch, fpu ? null
}:
with nixpkgs.lib;
let
  pkgs = import nixpkgs.outPath {
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
  packages = with pkgs.buildPackages; [
    kconfig-frontends genromfs xxd
    openocd
    gcc gdb
  ];
  inputsFrom = [ default c ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
