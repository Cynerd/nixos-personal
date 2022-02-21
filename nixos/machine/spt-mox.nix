{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    networking = {
      vlans = {
        "eth0.2" = {
          id = 2;
          interface = "eth0";
        };
      };
      bridges = {
        brlan = {
          interfaces = [
            "eth0" "lan1" "lan2" "lan3" "lan4"
          ];
        };
        brguest = {
          interfaces = [
            "eth0.2"
          ];
        };
      };
      dhcpcd.allowInterfaces = [ "brlan" ];
    };
  };

}
