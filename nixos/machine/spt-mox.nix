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
      interfaces.brlan = {
        ipv4 = {
          addresses = [{
            address = config.cynerd.hosts.spt.mox;
            prefixLength = 24;
          }];
        };
      };
      defaultGateway = config.cynerd.hosts.spt.omnia;
      nameservers = [ config.cynerd.hosts.spt.omnia "1.1.1.1" "8.8.8.8" ];
      dhcpcd.allowInterfaces = [ "brlan" ];
    };
  };

}
