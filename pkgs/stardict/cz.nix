{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (attrs: {
  pname = "stardict-cz";
  version = "20171101";

  src = fetchurl {
    url = "https://dl.cihar.com/slovnik/stable/stardict-czech-${attrs.version}.tar.gz";
    hash = "sha256-/wOelkE+XZwKZE+IFxUf89OmdMyn+ym0PKcNXRmAbJI=";
  };

  installPhase = ''
    mkdir -p $out/usr/share/stardict/dic
    cp czech-cizi.* $out/usr/share/stardict/dic/
  '';

  meta = with lib; {
    description = "Czech dictionary of foreign words for stardict";
    homepage = "http://slovnik.zcu.cz/";
    license = licenses.gpl3;
  };
})
