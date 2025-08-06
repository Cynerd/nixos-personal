{
  python3Packages,
  fetchFromGitHub,
  qt6,
  copyDesktopItems,
}:
python3Packages.buildPythonApplication {
  pname = "dodo";
  version = "250806";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "akissinger";
    repo = "dodo";
    rev = "bcb0db840f6eb0223f99e9ddefe147d84f50dc98";
    hash = "sha256-ScMzSz6HzSUHE5jOrXvcMaokQILaXJV58k87SXujaXg=";
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
