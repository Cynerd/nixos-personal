{
  pkgs,
  default,
  c,
}:
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
  meta.platforms = pkgs.lib.platforms.linux;
}
