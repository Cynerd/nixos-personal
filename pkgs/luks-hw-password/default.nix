{ lib, stdenvNoCC, makeWrapper
, dmidecode, coreutils
}:

stdenvNoCC.mkDerivation {
  pname = "luks-hw-password";
  version = "1.0";
  meta = with lib; {
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

  nativeBuildInputs = [ makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${./luks-hw-password.sh} $out/bin/luks-hw-password \
      --prefix PATH : ${lib.makeBinPath [ dmidecode coreutils ]}
  '';
}
