{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options = {
    cynerd.compile = mkOption {
      type = types.bool;
      default = false;
      description = "If machine is about to be used for compilation.";
    };
  };

  config = mkIf config.cynerd.compile {
    nix.settings = {
      max-jobs = 32;
      cores = 0;
    };

    boot.binfmt.emulatedSystems = ["armv7l-linux" "aarch64-linux" "riscv32-linux"];

    environment.systemPackages = with pkgs; [
      # Tools
      git
      bash
      #uroot
      qemu

      # Python
      python3Packages.pip
    ];
  };
}
