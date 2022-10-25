{ nixpkgs, shellrc, system }:
let

  callDevelop = nixpkgs.lib.callPackageWith ({
      inherit system;
      inherit nixpkgs;
    } // shells);

  shells = {
    default = nixpkgs.legacyPackages.${system}.mkShell {
      inputsFrom = [ shellrc.packages.${system}.default ];
    };

    armv6 = callDevelop ./nuttx.nix { arch = "armv6s-m"; };
    armv7e = callDevelop ./nuttx.nix { arch = "armv7e-m"; fpu = "vfpv3-d16"; };
    espc = callDevelop ./nuttx.nix { arch = "rv32imc"; };
    c = callDevelop ./c.nix { };
    qt = callDevelop ./qt.nix { };
    riscv = callDevelop ./riscv.nix { };
  };

in shells
