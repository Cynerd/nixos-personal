{
  system,
  nixpkgs,
  default,
  c,
}: let
  pkgs = nixpkgs.legacyPackages.${system};
in
  pkgs.mkShell {
    packages = with pkgs;
    with libsForQt5; [
      #full
      qtbase
      qtserialport
      qtwebsockets
      doctest
      qtcharts
      qtwayland

      (stdenv.mkDerivation {
        pname = "qcoro";
        version = "0.6.1";
        src = fetchFromGitHub {
          owner = "danvratil";
          repo = "qcoro";
          rev = "261663560f59a162c0c82158a6cde41089668871";
          sha256 = "OAYJpoW3b0boSYBfuzLrFvlYSmP3SON8O6HsDQoi+I8=";
        };
        buildInputs = [qtbase qtwebsockets];
        nativeBuildInputs = [wrapQtAppsHook cmake];
      })
    ];
    inputsFrom = with pkgs; [default c];
    meta.platforms = ["x86_64-linux"];
  }
