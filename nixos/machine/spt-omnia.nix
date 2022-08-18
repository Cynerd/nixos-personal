{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd = {
      openvpn.oldpersonal = true;
    };

    networking = {
      # TODO we need vlan filtering to filter out guest network
      bridges = {
        brlan = {
          interfaces = [
            "lan0" "lan1" "lan2" "lan3" "lan4"
          ];
        };
        #brguest = {
        #  interfaces = [
        #    "brlan.2" #"mlan0host" "wlp1s0host"
        #  ];
        #};
      };
      interfaces.brlan = {
        ipv4 = {
          addresses = [{
            address = config.cynerd.hosts.spt.omnia;
            prefixLength = 24;
          }];
        };
      };
      nameservers = [ "127.0.0.1" "1.1.1.1" "8.8.8.8" ];
      dhcpcd.allowInterfaces = [ "eth2" ];
    };

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;

      overrideDevices = false;
      overrideFolders = false;

      dataDir = "/data";
    };

  };

}
