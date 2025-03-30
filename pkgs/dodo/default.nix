{
  python3Packages,
  fetchFromGitHub,
  qt6,
  copyDesktopItems,
}:
python3Packages.buildPythonApplication {
  pname = "dodo";
  version = "250313";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "akissinger";
    repo = "dodo";
    rev = "c108dd93aa637ef757fa8d86cf210d37093f03ec";
    hash = "sha256-tRLaPOh2y87zcBKTtZazfsNzJnLUXRaAEMEMND7XnNY=";
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
