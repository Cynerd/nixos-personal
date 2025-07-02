{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  openssl,
  dtc,
  filesToInstall,
  platform ? null,
  extraMakeFlags ? [],
  extraMeta ? {},
}:
stdenv.mkDerivation {
  pname = "arm-trusted-firmware${lib.optionalString (platform != null) "-${platform}"}";
  version = "2025.02.12";

  src = fetchFromGitHub {
    owner = "mtk-openwrt";
    repo = "arm-trusted-firmware";
    rev = "e090770684e775711a624e68e0b28112227a4c38";
    hash = "sha256-VI5OB2nWdXUjkSuUXl/0yQN+/aJp9Jkt+hy7DlL+PMg=";
  };

  depsBuildBuild = [buildPackages.stdenv.cc];
  nativeBuildInputs = [dtc];
  buildInputs = [openssl];

  makeFlags =
    [
      "HOSTCC=$(CC_FOR_BUILD)"
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
      # Make the new toolchain guessing (from 2.11+) happy
      "CC=${stdenv.cc.targetPrefix}cc"
      "LD=${stdenv.cc.targetPrefix}cc"
      "AS=${stdenv.cc.targetPrefix}cc"
      "OC=${stdenv.cc.targetPrefix}objcopy"
      "OD=${stdenv.cc.targetPrefix}objdump"
      # Passing OpenSSL path according to docs/design/trusted-board-boot-build.rst
      "OPENSSL_DIR=${openssl}"
    ]
    ++ (lib.optional (platform != null) "PLAT=${platform}")
    ++ extraMakeFlags;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ${lib.concatStringsSep " " filesToInstall} $out

    runHook postInstall
  '';

  hardeningDisable = ["all"];
  dontStrip = true;

  meta = with lib;
    {
      homepage = "https://github.com/mtk-openwrt/arm-trusted-firmware";
      description = "MediaTek ARM Trusted Firmware";
      license = [licenses.bsd3];
      maintainers = with maintainers; [cynerd];
    }
    // extraMeta;
}
