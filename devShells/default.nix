pkgs: rec {
  armv7e = import ./nuttx.nix pkgs c {
    arch = "armv7e-m";
    fpu = "vfpv3-d16";
  };
  espc = import ./nuttx.nix pkgs c {arch = "rv32imc";};
  c = import ./c.nix pkgs;
  qt = import ./qt.nix pkgs c;
  python = import ./python.nix pkgs;
  apo = import ./apo.nix pkgs c;
}
