{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "stardict-de-cz";
  version = "20200501";

  src = fetchurl {
    url = "http://dl.cihar.com/slovnik/stable/stardict-german-czech-${version}.tar.gz";
    sha256 = "1d91pmflaz9zgblalk9b2ib6idj6akm64wvslmzsydwn738n6va2";
  };

  installPhase = ''
    mkdir -p $out/usr/share/stardict/dic
    cp czech-german.* $out/usr/share/stardict/dic/
    cp german-czech.* $out/usr/share/stardict/dic/
  '';

  meta = with lib; {
    description = "GNU/FDL German-Czech dictionary for StarDict";
    homepage = "http://slovnik.zcu.cz/";
    license = licenses.gpl3;
  };
}
