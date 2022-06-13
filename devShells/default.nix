{ nixpkgs, shellrc, system }:
let

  callDevelop = file: import file {
    inherit nixpkgs;
    inherit shellrc;
    inherit system;
  };

in {

  armv6 = callDevelop ./nuttx.nix { arch = "armv6s-m"; };
  armv7e = callDevelop ./nuttx.nix { arch = "armv7e-m"; fpu = "vfpv3-d16"; };
  c = callDevelop ./c.nix;
  riscv = callDevelop ./riscv.nix;

}
