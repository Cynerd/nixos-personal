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
  version = "2025.07.11";

  src = fetchFromGitHub {
    owner = "mtk-openwrt";
    repo = "arm-trusted-firmware";
    rev = "78a0dfd927bb00ce973a1f8eb4079df0f755887a";
    hash = "sha256-m9ApkBVf0I11rNg68vxofGRJ+BcnlM6C+Zrn8TfMvbY=";
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
