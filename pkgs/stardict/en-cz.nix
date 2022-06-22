{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "stardict-en-cz";
  version = "20210401";

  src = fetchurl {
    url = "http://dl.cihar.com/slovnik/stable/stardict-english-czech-${version}.tar.gz";
    sha256 = "1rh2ybqwzw258g4d4aydc587mbqqq7m7fzkxq9kf3b7x9xqzx6ia";
  };

  installPhase = ''
    mkdir -p $out/usr/share/stardict/dic
    cp czech-english.* $out/usr/share/stardict/dic/
    cp english-czech.* $out/usr/share/stardict/dic/
  '';

  meta = with lib; {
    description = "GNU/FDL English-Czech dictionary for StarDict";
    homepage = "http://slovnik.zcu.cz/";
    license = licenses.gpl3;
  };
}
