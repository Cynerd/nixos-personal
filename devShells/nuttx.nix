{ system, nixpkgs
, default, c
, arch, fpu ? null
}:
with nixpkgs.lib;
let
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-cross = import nixpkgs.outPath {
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
    kconfig-frontends genromfs xxd
    openocd
  ]) ++ (with pkgs-cross.buildPackages; [
    gcc gdb
  ]);
  inputsFrom = [ default c ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
