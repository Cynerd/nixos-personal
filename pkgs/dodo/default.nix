{
  python3Packages,
  fetchFromGitHub,
  qt6,
  copyDesktopItems,
}:
python3Packages.buildPythonApplication {
  pname = "dodo";
  version = "240917";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "akissinger";
    repo = "dodo";
    rev = "194fb49523c7851bedc3ca8c11adea04830fb28d";
    hash = "sha256-iGMIeGGqJnp0xi4q1Dpev4dkSp0tdFGu0U/MGeHrtcY=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    qt6.qtwayland
    bleach
    pyqt6
    pyqt6-webengine
    python-gnupg
    copyDesktopItems
  ];

  nativeBuildInputs = [qt6.wrapQtAppsHook];
  dontWrapQtApps = true;
  preFixup = ''
    wrapQtApp "$out/bin/dodo" --prefix PATH : $out/bin/dodo
  '';
}
