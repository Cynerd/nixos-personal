{ lib, mkFranzDerivation, fetchurl, xorg, xdg-utils, buildEnv, writeShellScriptBin }:

let
  mkFranzDerivation' = mkFranzDerivation.override {
    xdg-utils = buildEnv {
      name = "xdg-utils-for-ferdium";
      paths = [
        xdg-utils
        (lib.hiPrio (writeShellScriptBin "xdg-open" ''
          unset GDK_BACKEND
          exec ${xdg-utils}/bin/xdg-open "$@"
        ''))
      ];
    };
  };
in
mkFranzDerivation' rec {
  pname = "ferdium";
  name = "Ferdium";
  version = "6.0.0-nightly.80";
  src = fetchurl {
    url = "https://github.com/ferdium/ferdium-app/releases/download/v${version}/ferdium_${version}_amd64.deb";
    sha256 = "10gl3750nf2p6nqpm60ffbilrcr70wn2whwk94cyszq2d3nwg4cc";
  };
  extraBuildInputs = [ xorg.libxshmfence ];
  meta = with lib; {
    description = "Combine your favorite messaging services into one application";
    homepage = "https://ferdium.org/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
