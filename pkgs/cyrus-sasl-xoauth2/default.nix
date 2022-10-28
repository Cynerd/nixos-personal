{ lib, stdenv, fetchFromGitHub
, autoconf, automake, libtool, pkg-config
, cyrus_sasl
}:

with lib;

stdenv.mkDerivation rec {
  pname = "cyrus-sasl-xoauth2";
  version = "0.2";
  src = fetchFromGitHub {
    owner = "moriyoshi";
    repo = "cyrus-sasl-xoauth2";
    rev = "v${version}";
    sha256 = "lI8uKtVxrziQ8q/Ss+QTgg1xTObZUTAzjL3MYmtwyd8=";
  };

  nativeBuildInputs = [
    autoconf automake libtool pkg-config
  ];
  buildInputs = [
    cyrus_sasl
  ];

  preConfigure = ''
    ./autogen.sh
  '';
  installPhase = ''
    make DESTDIR=$out install
  '';
}
