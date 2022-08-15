{ system, nixpkgs, default }:
let
  pkgs = nixpkgs.legacyPackages.${system};

in pkgs.mkShell {
  packages = (with pkgs; [
    qt5.full
    cmake
  ]);
  inputsFrom = with pkgs; [ default ];
  meta.platforms = nixpkgs.lib.platforms.linux;
}
