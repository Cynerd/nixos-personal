self: let
  inherit (builtins) readDir;
  inherit (self.inputs) nixpkgs nixturris;
  inherit
    (nixpkgs.lib)
    filterAttrs
    composeManyExtensions
    hasSuffix
    nameValuePair
    nixosSystem
    removeSuffix
    mapAttrs
    mapAttrs'
    ;
in
  mapAttrs' (
    fname: _: let
      name = removeSuffix ".nix" fname;
    in
      nameValuePair name (nixosSystem {
        modules = [
          (./. + ("/" + fname))
          {networking.hostName = name;}
          self.nixosModules.default
        ];
        specialArgs = {
          inputModules =
            mapAttrs (v: v.nixosModules) self.inputs
            // {
              vpsadminos = self.inputs.vpsadminos.nixosConfigurations.container;
            };
          lib = nixpkgs.lib.extend (composeManyExtensions [
            nixturris.overlays.lib
            self.overlays.lib
          ]);
        };
      })
  )
  (filterAttrs (
    n: v:
      v == "regular" && n != "default.nix" && hasSuffix ".nix" n
  ) (readDir ./.))
