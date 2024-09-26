pkgs: rec {
  c = import ./c.nix pkgs;
  musl = import ./c.nix pkgs.pkgsMusl;
  #llvm = import ./c.nix pkgs.pkgsLLVM;
  apo = import ./apo.nix pkgs c;
}
