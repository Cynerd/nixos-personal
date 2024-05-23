{
  lib,
  default_modules ? [],
}: let
  inherit (builtins) readDir;
  inherit (lib) filterAttrs hasSuffix attrValues mapAttrs' nameValuePair removeSuffix;

  modules =
    mapAttrs'
    (fname: _: nameValuePair (removeSuffix ".nix" fname) (./. + ("/" + fname)))
    (filterAttrs (
      n: v:
        v == "regular" && n != "default.nix" && hasSuffix ".nix" n
    ) (readDir ./.));
in
  modules
  // {
    default = {
      imports = attrValues modules ++ default_modules;
    };
  }
