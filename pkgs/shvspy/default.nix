{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doctest,
  qt6,
  makeDesktopItem,
  copyDesktopItems,
}:
with qt6;
  stdenv.mkDerivation rec {
    name = "shvspy";

    src = fetchFromGitHub {
      owner = "silicon-heaven";
      repo = "shvspy";
      rev = "c8a3b52e7300f1f05a54569121da8a2e9bb015aa";
      hash = "sha256-+aknZ/Uo0VuMm45PHqSrvdyfD73hofS8HKVSfkIyM5I=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      cmake
      doctest
      wrapQtAppsHook
      copyDesktopItems
    ];
    buildInputs = [
      qtbase
      qtserialport
      qtwebsockets
      qtsvg
      doctest
    ];

    desktopItems = [
      (makeDesktopItem {
        name = "shvspy";
        exec = "shvspy";
        desktopName = "SHVSpy";
        categories = ["Network" "RemoteAccess"];
      })
    ];

    meta = with lib; {
      description = "Console version of Stardict program";
      homepage = "https://dushistov.github.io/sdcv/";
      license = licenses.gpl2;
    };
  }
