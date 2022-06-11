{ lib, stdenvNoCC, makeWrapper
, bash, jq, sway, swaylock
, background-lnxpcs
}:

stdenvNoCC.mkDerivation {
  pname = "myswaylock";
  version = "1.0";
  meta = with lib; {
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

  nativeBuildInputs = [ makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${./myswaylock.sh} $out/bin/myswaylock
    wrapProgram $out/bin/myswaylock \
      --prefix PATH : ${lib.makeBinPath [ bash jq sway swaylock ]} \
      --prefix BACKGROUND_LNXPCS : ${ background-lnxpcs }
  '';
}
