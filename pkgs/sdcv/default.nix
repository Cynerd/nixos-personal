{ lib, stdenv, fetchFromGitHub
, cmake, pkg-config, gettext
, zlib, glib, pcre, readline
}:

stdenv.mkDerivation rec {
  pname = "sdcv";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "Dushistov";
    repo = pname;
    rev = "d054adb37c635ececabc31b147c968a480d1891a";
    hash = "sha256-mJ9LrQ/l0SRmueg+IfGnS0NcNheGdOZ2Gl7KMFiK6is=";
  };

  nativeBuildInputs = [ cmake pkg-config gettext ];
  buildInputs = [ zlib glib pcre readline ];
  makeFlags = "sdcv lang";

  meta = with lib; {
    description = "Console version of Stardict program";
    homepage = "https://dushistov.github.io/sdcv/";
    license = licenses.gpl2;
  };
}
