self: let
  machines = import ./machine self;
  modules = import ./modules self;
  routers = import ./routers;
in
  modules
  // machines
  // {
    default = {
      imports = with self.inputs;
        [
          shellrc.nixosModules.default
          usbkey.nixosModules.default
          nixbigclown.nixosModules.default
        ]
        ++ builtins.attrValues modules;
    };
    defaultRouters = {imports = builtins.attrValues routers;};
  }
