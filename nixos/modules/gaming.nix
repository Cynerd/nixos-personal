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

    nixpkgs.config.permittedInsecurePackages = [
      "SDL_ttf-2.0.11" # TODO
    ];

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
            xorg.libXpm
            #flac134
            libopus
          ];
      };
      heroic = pkgs.heroic.override {
        extraPkgs = pkgs:
          with pkgs; [
            ncurses
            xorg.libXpm
            #flac134
            libopus
            SDL
            SDL2_image
            SDL2_mixer
            SDL2_ttf
            SDL_image
            SDL_mixer
            SDL_ttf
            glew110
            libdrm
            libidn
            tbb
          ];
      };
    };
  };
}
