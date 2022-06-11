{ nixpkgs, shellrc, system }: {

  riscv = import ./riscv.nix { inherit nixpkgs; inherit shellrc; inherit system; };

}
