{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (attrs: {
  pname = "stardict-en-cz";
  version = "20210401";

  src = fetchurl {
    url = "http://dl.cihar.com/slovnik/stable/stardict-english-czech-${attrs.version}.tar.gz";
    hash = "sha256-Kpr+cU/9rOFmwn1+d+rBGK96UGHNK9LIQ0Xwz/HyAuY=";
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
})
