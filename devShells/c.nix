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

    # Qt6
    qt6.qttools
    qt6.qtbase
    qt6.qttranslations
    qt6.qtserialport
    qt6.qtwebsockets
    qt6.qtcharts
    qt6.qtsvg
    qt6.qtnetworkauth
    qt6.qtwayland
    qt6.wrapQtAppsHook
  ];
  meta.platforms = pkgs.lib.platforms.linux;
}
