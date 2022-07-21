{ system, nixpkgs, default }:
let
  pkgs = nixpkgs.legacyPackages.${system};

in pkgs.mkShell {
  packages = (with pkgs; [
    clang-tools
    gcc gdb pkg-config
    cppcheck flawfinder bear
    meson
    lcov massif-visualizer
  ]);
  inputsFrom = with pkgs; [
    check
    curl

    default
  ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
