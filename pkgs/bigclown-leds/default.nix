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
    name = "bigclown-leds";
    src = fetchgit {
      url = "https://git.cynerd.cz/bigclown-leds";
      rev = "f84a97b9bf2665dea91f71fb1b0f938eeb725ccf";
      hash = "sha256-jNbjgf1WdpgK5keSAPhyOXjt8YT8hcVDmkZ3uI2rnwE=";
    };

    nativeBuildInputs = [makeWrapper];
    installPhase = ''
      mkdir -p $out/bin
      cp bigclown-leds $out/bin/
      wrapProgram $out/bin/bigclown-leds \
        --prefix PATH : ${lib.makeBinPath [python]}
    '';
  }
