{ lib, stdenvNoCC, makeWrapper
, bash, jq, sway
, background-lnxpcs
}:

stdenvNoCC.mkDerivation {
  pname = "swaybackground";
  version = "1.0";

  nativeBuildInputs = [ makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${./swaybackground.sh} $out/bin/swaybackground
    wrapProgram $out/bin/swaybackground \
      --prefix PATH : ${lib.makeBinPath [ bash jq sway ]} \
      --prefix BACKGROUND_LNXPCS : ${ background-lnxpcs }
  '';
}
