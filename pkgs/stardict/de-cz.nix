{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (attrs: {
  pname = "stardict-de-cz";
  version = "20200501";

  src = fetchurl {
    url = "http://dl.cihar.com/slovnik/stable/stardict-german-czech-${attrs.version}.tar.gz";
    hash = "sha256-Qm1j0TiWN69/pXpzYupURrZoVhQrTaroej99RV29IbU=";
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
})
