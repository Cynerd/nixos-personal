_: {
  system.stateVersion = "25.11";
  deploy = {
    enable = true;
    ssh.host = "zd-one0";
  };

  cynerd = {
    openwrtone = true;
    #switch = {
    #  enable = true;
    #  lanAddress = "10.8.12.10/24";
    #  lanGateway = config.cynerd.hosts.spt.omnia;
    #};
    #wifiAP.zd = {
    #  enable = false;
    #  qca988x = {
    #    interface = "wlp1s0";
    #    bssids = config.secrets.wifiMacs.zd-mox.qca988x;
    #    channel = 36;
    #  };
    #};
  };

  boot.initrd.availableKernelModules = ["dm-mod"];
  boot.consoleLogLevel = 7;

  services = {
    journald.extraConfig = ''
      SystemMaxUse=8G
    '';

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };

    fail2ban = {
      enable = true;
      ignoreIP = ["10.8.0.0/24" "10.8.1.0/24" "10.8.2.0/24"];
    };
  };

  networking.useDHCP = false;
  networking.useNetworkd = true;

  systemd.network = {
    networks = {
      "eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          Address = "10.8.2.10/24";
          Gateway = "10.8.2.1";
          DNS = "1.1.1.1";
          IPv6AcceptRA = "yes";
        };
      };
    };
    wait-online.anyInterface = true;
  };
}
