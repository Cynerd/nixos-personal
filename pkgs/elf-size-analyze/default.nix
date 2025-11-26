{
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication {
  pname = "elf-size-analyze";
  version = "20250901";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jedrzejboczar";
    repo = "elf-size-analyze";
    rev = "9cff8203c8616a1be2adfd1b8cd114069049ea58";
    hash = "sha256-HaLBwUBx51cvFKwhMCfy+0EOP3kNtsl19e7sKU893J0=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-git-versioning
  ];
}
