{ lib, stdenvNoCC, makeWrapper
, bash, jq, sway
, background-lnxpcs
}:

stdenvNoCC.mkDerivation {
  pname = "swaybackground";
  version = "1.0";
  meta = with lib; {
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

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
