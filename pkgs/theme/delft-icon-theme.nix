{ lib, stdenv, stdenvNoCC, fetchFromGitHub, gtk3, gnome-icon-theme, hicolor-icon-theme }:

stdenv.mkDerivation rec {
  pname = "delft-icon-theme";
  version = "1.15";

  src = fetchFromGitHub {
    owner = "madmaxms";
    repo = "iconpack-delft";
    rev = "v${version}";
    sha256 = "fluSh2TR1CdIW54wkUp1QRB0m9akFKnSn4d+0z6gkLA=";
  };

  nativeBuildInputs = [ gtk3 ];

  propagatedBuildInputs = [ gnome-icon-theme hicolor-icon-theme ];

  dontDropIconThemeCache = true;

  installPhase = ''
    mkdir -p $out/share/icons
    cp -a Delft* $out/share/icons/

    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  meta = with lib; {
    description = "Delft icon theme";
    homepage = "https://github.com/madmaxms/iconpack-delft";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
