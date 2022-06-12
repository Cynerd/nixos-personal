{ nixpkgs, shellrc, system }:
let

  callDevelop = file: import file {
    inherit nixpkgs;
    inherit shellrc;
    inherit system;
  };

in {

  armv6 = callDevelop ./nuttx.nix "armv6-m";
  armv7e = callDevelop ./nuttx.nix "armv7e-m";
  riscv = callDevelop ./riscv.nix;

}
