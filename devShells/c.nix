pkgs:
pkgs.mkShell {
  packages = with pkgs; [
    clang-tools_14
    ctags
    gcc
    gdb
    pkg-config

    autoconf
    automake
    libtool

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

    # Qt
    libsForQt5.qtbase
    libsForQt5.qttranslations
    libsForQt5.qtserialport
    libsForQt5.qtwebsockets
    libsForQt5.qtcharts
    libsForQt5.qtwayland
  ];
  meta.platforms = pkgs.lib.platforms.linux;
}
