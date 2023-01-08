{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.cynerd.autounlock;
in {
  options = {
    cynerd.autounlock = mkOption {
      type = with types; attrsOf string;
      default = {};
      description = "Devices to be auto-unlocked.";
    };
  };

  config = mkIf (cnf != {}) {
    environment.systemPackages = [pkgs.luks-hw-password];
    boot.initrd = {
      extraFiles."/luks-hw-password".source = pkgs.luks-hw-password;
      luks.devices =
        mapAttrs (name: value: {
          device = value;
          keyFile = "/keys/${name}.key";
          fallbackToPassword = true;
          preOpenCommands = ''
            mkdir -p /keys
            /luks-hw-password/bin/luks-hw-password > /keys/${name}.key
          '';
          postOpenCommands = ''
            rm -rf /keys
          '';
        })
        cnf;
    };
  };
}
