{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "stardict-cz";
  version = "20171101";

  src = fetchurl {
    url = "https://dl.cihar.com/slovnik/stable/stardict-czech-${version}.tar.gz";
    sha256 = "14kch0cms3d77js2kyx7risadlzk3waig22gch59qp9y86b9w0zz";
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
}
