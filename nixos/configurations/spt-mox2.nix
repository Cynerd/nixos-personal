{
  config,
  pkgs,
  ...
}: {
  turris.board = "mox";
  deploy = {
    enable = true;
    ssh.host = "mox2.spt";
  };

  cynerd = {
    monitoring.drives = false;
    switch = {
      enable = true;
      lanAddress = "${config.cynerd.hosts.spt.mox2}/24";
      lanGateway = config.cynerd.hosts.spt.omnia;
    };
    wifiAP.spt = {
      enable = true;
      qca988x = {
        interface = "wlp1s0";
        bssids = ["04:f0:21:45:d3:47" "08:f0:21:45:d3:47"];
        channel = 1;
      };
    };
  };

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_6_1_turris_mox;
  services.journald.extraConfig = ''
    SystemMaxUse=512M
  '';

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network.networks = {
    "lan-brlan" = {
      matchConfig.Name = "end0";
      networkConfig.Bridge = "brlan";
      bridgeVLANs = [
        {
          EgressUntagged = 1;
          PVID = 1;
        }
        {VLAN = 2;}
      ];
    };
  };
}
