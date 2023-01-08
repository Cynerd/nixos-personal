{
  lib,
  stdenvNoCC,
  makeShellWrapper,
  bash,
  nix,
  devShells,
}:
with lib; let
  shells = concatStringsSep ":" (mapAttrsToList (
      n: v: "${n}=${v.drvPath}=${v}"
    )
    devShells);
in
  stdenvNoCC.mkDerivation rec {
    name = "personal-devshells";
    src = ./.;

    nativeBuildInputs = [makeShellWrapper];
    installPhase = ''
      makeShellWrapper ${./dev.sh} $out/bin/dev \
        --prefix PATH : ${lib.makeBinPath [bash nix]} \
        --set DEV_SHELLS "${shells}"
    '';
  }
