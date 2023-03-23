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
        wan = "pppoe-wan";
        lanIP = config.cynerd.hosts.spt.omnia;
      };
      wifiAP.spt = {
        enable = true;
        ar9287.interface = "wlp3s0";
        qca988x.interface = "wlp2s0";
      };
      openvpn.oldpersonal = true;
      monitoring.speedtest = true;
    };

    networking.vlans."end2.848" = {
      id = 848;
      interface = "end2";
    };
    # TODO pppd service requires end2.848 interface
    services.pppd = {
      enable = true;
      peers."wan".config = ''
        plugin pppoe.so end2.848
        ifname pppoe-wan
        lcp-echo-interval 1
        lcp-echo-failure 5
        lcp-echo-adaptive
        +ipv6
        defaultroute
        defaultroute6
        usepeerdns
        maxfail 1
        user metronet
        password metronet
      '';
    };

    networking.bridges = {
      brlan.interfaces = ["lan0" "lan1" "lan2" "lan3" "lan4"];
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
