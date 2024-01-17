{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    cynerd = {
      router = {
        enable = true;
        wan = "end2"; # TODO pppoe-wan
        lanIP = config.cynerd.hosts.adm.omnia;
      };
      wifiAP.adm = {
        enable = true;
        ar9287.interface = "wlp3s0";
        qca988x.interface = "wlp2s0";
      };
      openvpn.oldpersonal = false;
      monitoring.speedtest = true;
    };

    services.pppd = {
      enable = false;
      peers."wan".config = ''
        plugin pppoe.so end2
        ifname pppoe-wan
        lcp-echo-interval 1
        lcp-echo-failure 5
        lcp-echo-adaptive
        +ipv6
        defaultroute
        defaultroute6
        usepeerdns
        maxfail 1
        user O2
        password 02
      '';
    };
    #systemd.services."pppd-wan".after = ["sys-subsystem-net-devices-end2.device"];

    environment.systemPackages = [pkgs.tcpdump];

    networking = {
      useNetworkd = true;
      useDHCP = false;
    };
    systemd.network.networks = {
      "lan-brlan" = {
        matchConfig.Name = "lan[1-4]";
        networkConfig.Bridge = "brlan";
      };
      "lan0-brguest" = {
        matchConfig.Name = "lan0";
        networkConfig.Bridge = "brguest";
      };
    };
  };
}
