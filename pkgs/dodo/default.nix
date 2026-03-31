{
  python3Packages,
  fetchFromGitHub,
  qt6,
  copyDesktopItems,
}:
python3Packages.buildPythonApplication {
  pname = "dodo";
  version = "20250926";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "akissinger";
    repo = "dodo";
    rev = "a710d0a3fe78d5bf4b3d07ea087712d3581e5a85";
    hash = "sha256-IylZCG/7egGA7IBfSIMwmSbJVRv5cMWEtiIyds720Sw=";
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
