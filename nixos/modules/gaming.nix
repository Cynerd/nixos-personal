{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types;
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

    environment.systemPackages = [pkgs.heroic];

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
