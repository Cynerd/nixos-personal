{
  config,
  lib,
  pkgs,
  ...
}:
with builtins;
with lib; {
  config = {
    cynerd = {
      home-assistant = true;
      wifiAP.spt = {
        enable = false;
        qca988x = {
          interface = "wls1";
          channel = 7;
        };
      };
    };

    networking = {
      vlans = {
        "brlan.guest" = {
          id = 2;
          interface = "brlan";
        };
      };
      bridges = {
        brlan.interfaces = ["eth0" "lan1" "lan2" "lan3" "lan4"];
        brguest.interfaces = ["brlan.guest"];
      };
      interfaces.brlan.ipv4.addresses = [
        {
          address = config.cynerd.hosts.spt.mox;
          prefixLength = 24;
        }
      ];
      defaultGateway = config.cynerd.hosts.spt.omnia;
      nameservers = ["1.1.1.1" "8.8.8.8"];
      dhcpcd.allowInterfaces = [];
    };

    # TODO: ubootTools build is broken!
    firmware.environment.enable = false;
  };
}
