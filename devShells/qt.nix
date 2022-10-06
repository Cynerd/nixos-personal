{ system, nixpkgs
, default, c
}:
let
  pkgs = nixpkgs.legacyPackages.${system};

in pkgs.mkShell {
  packages = (with pkgs; with libsForQt5; [
    qt5.full
    doctest

    (qcoro.overrideAttrs (oldAttrs: {
      version =  "0.6.1";
      src = fetchFromGitHub {
        owner = "danvratil";
        repo = "qcoro";
        rev = "261663560f59a162c0c82158a6cde41089668871";
        sha256 = "OAYJpoW3b0boSYBfuzLrFvlYSmP3SON8O6HsDQoi+I8=";
      };
      buildInputs = oldAttrs.buildInputs ++ [qt5.full];
    }))
  ]);
  inputsFrom = with pkgs; [ default c ];
  meta.platforms = ["x86_64-linux"];
}
