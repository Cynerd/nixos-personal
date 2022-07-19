{ lib, stdenv, fetchurl
, autoreconfHook, wrapGAppsHook
, pkg-config, automake, autoconf, libtool, intltool, gnome-doc-utils, libxslt
, gnome2, gtk2, libxml2, enchant , mariadb-connector-c, pcre
, speech-tools, speech-toolsDisable ? false
, espeak, espeakDisable ? false
}:

with lib;

stdenv.mkDerivation rec {
  pname = "stardict";
  version = "3.0.6";

  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/stardict-4/${version}/stardict-${version}.tar.bz2";
    sha256 = "1rw2dg1d489gjjx9957j2jdmjlvylv31pnx3142lwq3pi5d6j2ka";
  };
  patches = [
    ./enchant2.patch
    ./gcc46.patch
    ./gconf.patch
    ./glib2.patch
    ./makefile.patch
    ./mariadb.patch
  ];

  nativeBuildInputs = [
    autoreconfHook wrapGAppsHook
    pkg-config intltool gnome-doc-utils libxslt
  ];
  buildInputs = [
    gnome2.gnome-common gnome2.GConf
    gtk2 libxml2 enchant mariadb-connector-c pcre
   ]
   ++ optional (!speech-toolsDisable) speech-tools
   ++ optional (!espeakDisable) espeak;
  configureFlags = [
    "--disable-gnome-support"
    "--disable-gucharmap"
    "--disable-scrollkeeper"
    "--disable-festival"
    "--disable-gpe-support"
    "--disable-schemas-install"
  ]
  ++ optional speech-toolsDisable "--disable-speech-tools"
  ++ optional espeakDisable "--disable-espeak";

  meta = with lib; {
    description = "Cross-platform and international dictionary software";
    homepage = "http://stardict-4.sourceforge.net/";
    platform = platforms.linux;
    license = licenses.gpl3;
  };
}
