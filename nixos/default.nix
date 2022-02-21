nixpkgs:

let

  modules = import ./modules nixpkgs;
  machines = import ./machine;

in modules // machines // {
  default = { imports = builtins.attrValues modules; };
}
