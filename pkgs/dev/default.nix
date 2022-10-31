{ lib, stdenvNoCC
, makeShellWrapper, bash, nix
, devShells
}:

with lib;

let

  shells = concatStringsSep ":" (mapAttrsToList (n: v: "${n}=${v}") devShells);

in stdenvNoCC.mkDerivation rec {
  name = "personal-devshells";
  src = ./.;

  nativeBuildInputs = [ makeShellWrapper ];
  installPhase = ''
    makeShellWrapper ${./dev.sh} $out/bin/dev \
      --prefix PATH : ${lib.makeBinPath [ bash nix ]} \
      --set DEV_SHELLS "${shells}" \
      --set DEV_FLAKE "${../..}"
  '';

  meta = with lib; {
    description = "Console version of Stardict program";
    homepage = "https://dushistov.github.io/sdcv/";
    license = licenses.gpl2;
  };
}
