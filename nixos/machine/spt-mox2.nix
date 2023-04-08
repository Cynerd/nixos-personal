{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    cynerd = {
      wifiAP.spt = {
        enable = true;
        qca988x = {
          interface = "wls1";
          channel = 7;
        };
      };
    };

    swapDevices = [
      {
        device = "/dev/disk/by-partlabel/NixTurrisSwap";
        priority = 1;
      }
    ];

    networking = {
      vlans = {
        "brlan.guest" = {
          id = 2;
          interface = "brlan";
        };
      };
      bridges = {
        brlan.interfaces = ["eth0"];
        brguest.interfaces = ["brlan.guest"];
      };
      interfaces.brlan.ipv4.addresses = [
        {
          address = config.cynerd.hosts.spt.mox2;
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
