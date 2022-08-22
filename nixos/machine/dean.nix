{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd = {
      openvpn = {
        oldpersonal = true;
      };
    };

    #boot.kernelPatches = [{
    #  name = "rwtm";
    #  patch = null;
    #  extraConfig = ''
    #    TURRIS_MOX_RWTM y
    #    ARMADA_37XX_RWTM_MBOX y
    #    '';
    #}];

    networking = {
      bridges = {
        brlan = {
          interfaces = [
            "eth0" "lan1" "lan2" "lan3" "lan4"
          ];
        };
      };
      dhcpcd.allowInterfaces = [ "brlan" ];
    };

    swapDevices = [{
      device = "/var/swap";
      priority = 1;
    }];

    environment.systemPackages = with pkgs; [
      #openocd
      sterm
    ];

  };

}
