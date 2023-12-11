self:
with builtins; let
  machines = import ./machine self;
  modules = import ./modules;
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
        ++ attrValues modules;
    };
    defaultRouters = {imports = attrValues routers;};
  }
