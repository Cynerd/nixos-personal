{lib}: let
  inherit (builtins) readDir;
  inherit (lib) filterAttrs hasSuffix mapAttrs' nameValuePair removeSuffix;
in
  mapAttrs'
  (fname: _: nameValuePair (removeSuffix ".nix" fname) (./. + ("/" + fname)))
  (filterAttrs (
    n: v:
      v == "regular" && n != "default.nix" && hasSuffix ".nix" n
  ) (readDir ./.))
