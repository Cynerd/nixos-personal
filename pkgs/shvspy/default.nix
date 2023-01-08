{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doctest,
  libsForQt5,
  qcoro_task_exception_handling,
  makeDesktopItem,
  copyDesktopItems,
}:
with libsForQt5;
  stdenv.mkDerivation rec {
    name = "shvspy";

    src = fetchFromGitHub {
      owner = "silicon-heaven";
      repo = "shvspy";
      rev = "a922e963bf7884164fe2b124a7a4366f7fc802a3";
      sha256 = "ExA+sFlkxFKXk69DKoGzKm80ypiNFwN281MwZkMgaVY=";
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
      doctest
      qcoro_task_exception_handling
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
