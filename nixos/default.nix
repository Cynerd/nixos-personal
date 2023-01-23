self:
with builtins; let
  machines = import ./machine self;
  modules = import ./modules;
  routers = import ./routers;
in
  modules
  // machines
  // {
    default = {imports = attrValues modules;};
    defaultRouters = {imports = attrValues routers;};
  }
