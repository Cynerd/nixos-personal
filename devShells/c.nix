{ system, nixpkgs
, default
}:
let
  pkgs = nixpkgs.legacyPackages.${system};

in pkgs.mkShell {
  packages = (with pkgs; [

    clang-tools_14 ctags
    gcc gdb pkg-config

    gnumake bear
    meson ninja
    cmake

    valgrind
    lcov massif-visualizer
    cppcheck flawfinder

    check
    curl
    ncurses
    flex bison gperf
    gtk3 gtk4

    # Various libraries
    openssl.dev zlib.dev curl.dev libconfig
    czmq libevent.dev

    # LVGL
    SDL2 libffi.dev

    (python3.withPackages (pypkgs: with pypkgs; [
      schema jinja2 ruamel-yaml
    ]))
  ]);
  inputsFrom = with pkgs; [ default ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
