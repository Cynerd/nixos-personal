{ system, nixpkgs, default }:
let
  pkgs = nixpkgs.legacyPackages.${system};

in pkgs.mkShell {
  packages = (with pkgs; [

    clang-tools
    gcc gdb pkg-config

    meson ninja bear
    cmake

    cppcheck flawfinder

    lcov massif-visualizer

    check
    curl
    gtk3 gtk4

    # LVGL
    SDL2 libffi.dev
  ]);
  inputsFrom = with pkgs; [ default ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
