{ lib, stdenv, makeBinaryWrapper
, sdcv-unwrapped
}:

with sdcv-unwrapped;

let

 drv = stdenv.mkDerivation rec {
    inherit pname;
    inherit version;
    inherit meta;

    nativeBuildInputs = [ sdcv-unwrapped makeBinaryWrapper ];
    dictionaries = [ /* empty and expecting override */ ];

    phases = [ "installPhase" ];
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
      makeWrapper ${sdcv-unwrapped}/bin/sdcv $out/bin/sdcv \
        --set STARDICT_DATA_DIR $out/usr/share/stardict/dic
    '';

    passthru.withDictionaries = dicts: drv.overrideAttrs (oldAttrs: {
      dictionaries = dicts;
    });
  };

in drv
