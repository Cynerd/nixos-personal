pkgs: rec {
  c = import ./c.nix pkgs [pkgs.gcc pkgs.gdb];
  #clang = import ./c.nix pkgs [pkgs.clang];
  #musl = import ./c.nix pkgs.pkgsMusl;
  #llvm = import ./c.nix pkgs.pkgsLLVM;
  #apo = import ./apo.nix pkgs c;
}
