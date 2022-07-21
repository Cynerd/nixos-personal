{ nixpkgs, shellrc, system }:
let

  default = let
    pkgs = nixpkgs.legacyPackages.${system};
  in pkgs.mkShell {
    inputsFrom = with pkgs; [
      shellrc.packages.${system}.default
    ];
  };

  callDevelop = file: import file {
    inherit system;
    inherit nixpkgs;
    inherit default;
  };

in {

  default = default;
  armv6 = callDevelop ./nuttx.nix { arch = "armv6s-m"; };
  armv7e = callDevelop ./nuttx.nix { arch = "armv7e-m"; fpu = "vfpv3-d16"; };
  c = callDevelop ./c.nix;
  riscv = callDevelop ./riscv.nix;

}
