self: let
  modules = import ./modules;
  machines = import ./machine self;
in
  modules
  // machines
  // {
    default = {imports = builtins.attrValues modules;};
  }
