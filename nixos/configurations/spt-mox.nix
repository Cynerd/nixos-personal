{
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "24.05";
  turris.board = "mox";
  deploy = {
    enable = true;
    ssh.host = "mox.spt";
    configurationLimit = 8;
  };

  cynerd = {
    monitoring.drives = false;
    switch = {
      enable = true;
      lanAddress = "${config.cynerd.hosts.spt.mox}/24";
      lanGateway = config.cynerd.hosts.spt.omnia;
    };
    wifiAP.spt = {
      enable = true;
      qca988x = {
        interface = "wlp1s0";
        bssids = config.secrets.wifiMacs.spt-mox.qca988x;
        channel = 7;
      };
    };
  };

  services = {
    journald.extraConfig = ''
      SystemMaxUse=512M
    '';

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network.networks = {
    "lan-brlan" = {
      matchConfig.Name = "lan* end0";
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

  ##############################################################################
  networking.firewall.allowedTCPPorts = [
    1883 # Mosquitto
  ];
  services = {
    mosquitto = {
      enable = true;
      listeners = [
        {
          users = {
            cynerd = {
              acl = ["readwrite #"];
              passwordFile = "/run/secrets/mosquitto.cynerd.pass";
            };
            telegraf = {
              acl = ["read bigclown/node/#"];
              passwordFile = "/run/secrets/mosquitto.telegraf.pass";
            };
            bigclown = {
              acl = ["readwrite bigclown/#"];
              passwordFile = "/run/secrets/mosquitto.bigclown.pass";
            };
          };
        }
      ];
    };

    telegraf.extraConfig = {
      outputs.influxdb_v2 = [
        {
          urls = ["http://cynerd.cz:8086"];
          token = "$INFLUX_TOKEN";
          organization = "personal";
          bucket = "bigclown";
          tagpass.source = ["bigclown"];
        }
      ];
      inputs.mqtt_consumer = let
        consumer = data_type: topics: {
          tags = {source = "bigclown";};
          servers = ["tcp://localhost:1883"];
          inherit topics;
          username = "telegraf";
          password = "$MQTT_PASSWORD";
          data_format = "value";
          inherit data_type;
          topic_parsing = [
            {
              topic = "bigclown/node/+/+/+/+";
              measurement = "_/_/_/_/_/measurement";
              tags = "_/_/device/field/_/_";
            }
          ];
        };
      in [
        (consumer "float" [
          "bigclown/node/+/battery/+/voltage"
          "bigclown/node/+/thermometer/+/temperature"
          "bigclown/node/+/hygrometer/+/relative-humidity"
          "bigclown/node/+/lux-meter/+/illuminance"
          "bigclown/node/+/barometer/+/pressure"
          "bigclown/node/+/pir/+/event-count"
          "bigclown/node/+/push-button/+/event-count"
        ])
        (consumer "boolean" [
          "bigclown/node/+/flood-detector/+/alarm"
        ])
      ];
      processors.pivot = [
        {
          tag_key = "field";
          value_key = "value";
          tagpass.source = ["bigclown"];
        }
      ];
    };

    bcg = {
      enable = true;
      device = "/dev/ttyUSB0";
      baseTopicPrefix = "bigclown/";
      environmentFiles = ["/run/secrets/bigclown.env"];
      mqtt = {
        username = "bigclown";
        password = "\${MQTT_PASSWORD}";
      };
    };
  };

  systemd.services = {
    telegraf.wants = ["mosquitto.service"];

    bigclown-leds = {
      description = "Bigclown LEDs control";
      wantedBy = ["multi-user.target"];
      wants = ["mosquitto.service"];
      serviceConfig.ExecStart = "${pkgs.bigclown-leds}/bin/bigclown-leds /run/secrets/bigclown-leds.ini";
    };
  };
}
