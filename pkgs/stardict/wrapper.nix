{
  lib,
  stdenv,
  makeBinaryWrapper,
  stardict,
}:
with stardict; let
  drv = stdenv.mkDerivation rec {
    inherit pname;
    inherit version;
    inherit meta;

    nativeBuildInputs = [stardict makeBinaryWrapper];
    dictionaries = [
      /*
      empty and expecting override
      */
    ];

    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin $out/usr/share/stardict/dic
      for dic in $dictionaries; do
        for path in "$dic"/usr/share/stardict/dic/*; do
          [ -f "$path" ] || continue
          outln="$out/usr/share/stardict/dic/${"$"}{path##*/}"
          [ -e "$outln" ] && continue
          ln -sf "$path" "$outln"
        done
      done

      for bin in ${stardict}/bin/*; do
        makeWrapper "$bin" "$out/bin/${"$"}{bin##*/bin/}" \
          --set STARDICT_DATA_DIR "$out/usr/share/stardict/dic"
      done
    '';

    passthru.withDictionaries = dicts:
      drv.overrideAttrs (oldAttrs: {
        dictionaries = dicts;
      });
  };
in
  drv
