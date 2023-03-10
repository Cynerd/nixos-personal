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
      qtbase
      qttranslations
      qtserialport
      qtwebsockets
      doctest
      qtcharts
      qtwayland
    ];
    inputsFrom = with pkgs; [default c];
    meta.platforms = ["x86_64-linux"];
  }
