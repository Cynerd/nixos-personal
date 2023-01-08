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
    boot.binfmt.registrations = {
      aarch64-linux = {
        fixBinary = true;
        wrapInterpreterInShell = false;
        interpreter = (lib.systems.elaborate {system = "aarch64-linux";}).emulator pkgs;
        magicOrExtension = "\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xb7\\x00";
        mask = "\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xfe\\xff\\xff\\xff";
      };
      armv7l-linux = {
        fixBinary = true;
        wrapInterpreterInShell = false;
        interpreter = (lib.systems.elaborate {system = "armv7l-linux";}).emulator pkgs;
        magicOrExtension = "\\x7fELF\\x01\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x28\\x00";
        mask = "\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xfe\\xff\\xff\\xff";
      };
    };
    nix.settings.extra-platforms = [
      "aarch64-linux"
      "armv7l-linux"
    ];

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
