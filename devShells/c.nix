pkgs:
pkgs.mkShell {
  packages = with pkgs; [
    clang-tools_14
    ctags
    gcc
    gdb
    pkg-config

    gnumake
    bear
    meson
    ninja
    cmake

    valgrind
    lcov
    massif-visualizer
    cppcheck
    flawfinder

    check
    curl
    ncurses
    flex
    bison
    gperf
    gobject-introspection
    gtk3
    gtk4

    # Various libraries
    openssl.dev
    zlib.dev
    curl.dev
    libconfig
    czmq
    libevent.dev

    # LVGL
    SDL2
    libffi.dev
  ];
  meta.platforms = pkgs.lib.platforms.linux;
}
