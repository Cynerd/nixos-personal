pkgs: let
  callDevelop = pkgs.lib.callPackageWith (shells // {inherit pkgs;});

  shells = {
    default = pkgs.mkShell {
      packages = [];
    };

    armv6 = callDevelop ./nuttx.nix {arch = "armv6s-m";};
    armv7e = callDevelop ./nuttx.nix {
      arch = "armv7e-m";
      fpu = "vfpv3-d16";
    };
    espc = callDevelop ./nuttx.nix {arch = "rv32imc";};
    c = callDevelop ./c.nix {};
    qt = callDevelop ./qt.nix {};
    python = callDevelop ./python.nix {};
    apo = callDevelop ./apo.nix {};
  };
in
  shells
