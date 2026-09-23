{
  python3Packages,
  fetchFromGitHub,
  qt6,
  copyDesktopItems,
}:
python3Packages.buildPythonApplication {
  pname = "dodo";
  version = "20260730";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "akissinger";
    repo = "dodo";
    rev = "2d1c91a625ac026f7624f80a36b29c2a4bdd0f4f";
    hash = "sha256-v4eXwzmS3DFYQ/v8sQWnnsyGjflf+OhVbVNqXLrYmZE=";
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
