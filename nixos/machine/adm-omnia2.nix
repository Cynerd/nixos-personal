{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    networking = {
      bridges = {
        brlan = {
          interfaces = [
            "eth2"
            "lan0"
            "lan1"
            "lan2"
            "lan3"
            "lan4"
          ];
        };
      };
      localCommands = ''
        ip link set brlan type bridge vlan_filtering 1
        bridge vlan add dev eth2 vid 1 pvid untagged
        bridge vlan add dev eth2 vid 2
        bridge vlan add dev lan0 vid 2 pvid untagged
        bridge vlan add dev lan1 vid 2 pvid untagged
        bridge vlan add dev lan2 vid 2 pvid untagged
        bridge vlan add dev lan3 vid 2 pvid untagged
        bridge vlan add dev lan4 vid 1 pvid untagged
        bridge vlan add dev lan4 vid 2
      '';
      vlans = {
        "lan" = {
          id = 1;
          interface = "brlan";
        };
      };
      interfaces.lan = {
        ipv4 = {
          addresses = [
            {
              address = config.cynerd.hosts.adm.omnia2;
              prefixLength = 24;
            }
          ];
        };
      };
      defaultGateway = config.cynerd.hosts.adm.omnia;
      nameservers = [config.cynerd.hosts.adm.omnia "1.1.1.1" "8.8.8.8"];
      dhcpcd.allowInterfaces = ["lan"];
    };
  };
}
