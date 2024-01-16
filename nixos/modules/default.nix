self: let
  inherit (builtins) readDir;
  inherit (self.inputs.nixpkgs.lib) filterAttrs nameValuePair mapAttrs' hasSuffix removeSuffix;
in
  mapAttrs'
  (n: v: nameValuePair "cynerd-${removeSuffix ".nix" n}" (import (./. + "/${n}")))
  (filterAttrs
    (n: v: v == "regular" && hasSuffix ".nix" n && n != "default.nix")
    (readDir ./.))
