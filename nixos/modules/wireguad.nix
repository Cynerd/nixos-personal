{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cnf = config.cynerd.wireguard;
in {
  options = {
    cynerd.wireguard = {
      enable = mkEnableOption "Enable Wireguard";
    };
  };

  config =
    mkIf cnf.enable {
    };
}
