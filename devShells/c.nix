{ nixpkgs, shellrc, system }:
let
  pkgs = nixpkgs.legacyPackages.${system};

in pkgs.mkShell {
  packages = (with pkgs; [
    ccls gcc gdb
    cppcheck flawfinder bear
    meson
    lcov massif-visualizer
  ]);
  inputsFrom = with pkgs; [
    check

    shellrc.packages.${system}.default
  ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
