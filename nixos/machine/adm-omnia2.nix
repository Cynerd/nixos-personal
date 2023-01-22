{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    cynerd = {
      wifiAP.adm = {
        enable = true;
        w24.interface = "wlp3s0";
        w5.interface = "wlp2s0";
      };
    };

    networking = {
      vlans = {
        "brlan.guest" = {
          interface = "brlan";
          id = 100;
        };
      };
      bridges = {
        brlan.interfaces = [ "end2" "lan0" "lan1" "lan2" "lan3" "lan4" ];
        brguest.interfaces = ["brlan.guest"];
      };
      interfaces.brlan.ipv4.addresses = [
        {
          address = config.cynerd.hosts.adm.omnia2;
          prefixLength = 24;
        }
      ];
      defaultGateway = config.cynerd.hosts.adm.omnia;
      nameservers = ["1.1.1.1" "8.8.8.8"];
      dhcpcd.allowInterfaces = [];
    };
  };
}
