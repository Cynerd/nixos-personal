{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  zlib,
  glib,
  pcre,
  readline,
}:
stdenv.mkDerivation (attrs: {
  pname = "sdcv";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "Dushistov";
    repo = attrs.pname;
    rev = "v${attrs.version}";
    hash = "sha256-EyvljVXhOsdxIYOGTzD+T16nvW7/RNx3DuQ2OdhjXJ4=";
  };

  nativeBuildInputs = [cmake pkg-config gettext];
  buildInputs = [zlib glib pcre readline];
  makeFlags = "sdcv lang";

  meta = with lib; {
    description = "Console version of Stardict program";
    homepage = "https://dushistov.github.io/sdcv/";
    license = licenses.gpl2;
  };
})
