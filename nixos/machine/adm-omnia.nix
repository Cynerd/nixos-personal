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
        w24.interface = "wlp3s0";
        w5.interface = "wlp2s0";
      };
      openvpn.oldpersonal = false;
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

    networking.bridges = {
      brlan.interfaces = ["lan1" "lan2" "lan3" "lan4"];
      brguest.interfaces = ["lan0"];
    };
  };
}
