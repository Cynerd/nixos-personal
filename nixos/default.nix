self: let
  machines = import ./machine self;
  modules = import ./modules self;
in
  modules
  // machines
  // {
    default = {
      imports = with self.inputs;
        [
          nixosdeploy.nixosModules.default
          shellrc.nixosModules.default
          usbkey.nixosModules.default
          nixbigclown.nixosModules.default
        ]
        ++ builtins.attrValues modules;
    };
  }
