{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  imagemagick,
}:
stdenvNoCC.mkDerivation rec {
  pname = "background-lnxpcs";
  version = "20190411";

  src = fetchFromGitHub {
    owner = "cynerd";
    repo = "lnxpcs";
    rev = "fd4487e1989fc040490fa437a2651d37afcde637";
    sha256 = "vtyyG0EHRmgWlxHmHgeckwtOv7t3C+hsuTt/vBdrRQM=";
  };

  nativeBuildInputs = [imagemagick];

  wallpapers = "bash cron gcc gnu gnu-linux iptables kernel kill python root su sudo vim";
  buildPhase = ''
    for img in $wallpapers; do
      echo "Generating: $img"
      ./makemywall 1920 1080 "cards/black/$img-card-black.png"
      ./makemywall 2560 1440 "cards/black/$img-card-black.png"
      ./makemywall 2560 1600 "cards/black/$img-card-black.png"
    done
  '';

  installPhase = ''
    mkdir -p $out
    for img in $wallpapers; do
      mv $img-card-black-1920x1080.png $out/
      mv $img-card-black-2560x1440.png $out/
      mv $img-card-black-2560x1600.png $out/
    done
  '';

  meta = with lib; {
    description = "Background pictures from lnxpcs and relevant scripts";
    homepage = "https://mega.nz/#F!mXgW3apI!Tdikb01SoOaTmNLiaTRhMg";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
