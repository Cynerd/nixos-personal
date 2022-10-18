self:

let

  modules = import ./modules self.inputs.nixpkgs;
  machines = import ./machine self;

in modules // machines // {
  default = { imports = builtins.attrValues modules; };
}
