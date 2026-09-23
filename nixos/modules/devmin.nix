{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
in {
  options = {
    cynerd.devmin = mkOption {
      type = types.bool;
      default = false;
      description = "If machine is about to be used for remote development.";
    };
  };

  config = mkIf config.cynerd.devmin {
    environment.enableDebugInfo = true;

    users.groups.develop = {};
    users.users.cynerd.extraGroups = [
      "develop"
    ];

    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0660", GROUP="develop", SYMLINK+="stlinkv2_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="a600", ATTRS{idProduct}=="a003", MODE:="0660", GROUP="develop", SYMLINK+="aix_forte_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE:="0660", GROUP="develop", SYMLINK+="jlink_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2111", MODE:="0660", GROUP="develop", SYMLINK+="cmsip_dap_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="bef3", MODE:="0660", GROUP="develop", SYMLINK+="xds110_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00ff", MODE:="0660", GROUP="develop", SYMLINK+="xds110_update_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a2", MODE:="0660", GROUP="develop", SYMLINK+="ccdebugger_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1ab1", ATTRS{idProduct}=="0e11", MODE:="0660", GROUP="develop"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE:="0660", GROUP="develop", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1002", MODE:="0660", GROUP="develop", TAG+="uaccess"
    '';
  };
}
