{ config, lib, pkgs, ... }:

with lib;

{

  options = {
    cynerd.compile = mkOption {
      type = types.bool;
      default = false;
      description = "If machine is about to be used for compilation.";
    };
  };

  config = mkIf config.cynerd.compile {

    environment.systemPackages = with pkgs; [
      # Tools
      git bash
      #uroot
      qemu

      # Python
      python3Packages.pip

    ];

  };

}
