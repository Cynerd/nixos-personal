{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
in {
  turris.board = "mox";
  deploy.enable = true;

  cynerd = {
    wireguard = true;
    monitoring.speedtest = true;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    netdevs."brlab".netdevConfig = {
      Kind = "bridge";
      Name = "brlan";
    };
    networks = {
      "brlan" = {
        matchConfig.Name = "brlan";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
      };
      "lan-brlan" = {
        matchConfig.Name = "lan* end0";
        networkConfig.Bridge = "brlan";
      };
    };
    # TODO investigate why it doesn't work
    wait-online.enable = false;
  };

  environment.systemPackages = with pkgs; [
    #openocd
    tio
  ];
}
