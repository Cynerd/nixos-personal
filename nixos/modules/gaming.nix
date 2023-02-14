{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.cynerd.gaming;
in {
  options = {
    cynerd.gaming = mkOption {
      type = types.bool;
      default = false;
      description = "Enable gaming";
    };
  };

  config = mkIf cnf {
    cynerd.desktop.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            ncurses
          ];
      };
    };
  };
}
