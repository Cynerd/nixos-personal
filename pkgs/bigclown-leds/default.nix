{
  lib,
  stdenvNoCC,
  fetchgit,
  makeWrapper,
  python3,
}:
with lib; let
  python = python3.withPackages (pypkgs:
    with pypkgs; [
      paho-mqtt
    ]);
in
  stdenvNoCC.mkDerivation rec {
    name = "personal-devshells";
    src = fetchgit {
      url = "https://git.cynerd.cz/bigclown-leds";
      rev = "1a2c69a2152c315a964c0eb9b2673c70e52051b4";
      hash = "sha256-alApXwHZeUnNFkO2S+yw0qG18Wr5fF3ErGc0QIgPFU8=";
    };

    nativeBuildInputs = [makeWrapper];
    installPhase = ''
      mkdir -p $out/bin
      cp bigclown-leds $out/bin/
      wrapProgram $out/bin/bigclown-leds \
        --prefix PATH : ${lib.makeBinPath [python]}
    '';
  }
