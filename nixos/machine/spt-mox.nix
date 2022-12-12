{ config, lib, pkgs, ... }:

with builtins;
with lib;

{

  config = {

    environment.systemPackages = with pkgs; [
      mosquitto
    ];

    networking.wirelessAP = {
      enable = true;
      environmentFile = "/run/secrets/hostapd.env";
      interfaces = {
        "wlp4s0" = {
          countryCode = "CZ";
          channel = 7;
          hwMode = "g";
          ht_capab = ["HT40+" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "DSSS_CCK-40"];
          ssid = "TurrisRules";
          bridge = "brlan";
          wpa = true;
          wpa3 = false;
          wpaPassphrase = "@PASS_TURRIS_RULES@";
        };
        # TODO use use wlp3s0 with 80211ax
      };
    };

    networking = {
      vlans = {
        "eth0.2" = {
          id = 2;
          interface = "eth0";
        };
      };
      bridges = {
        brlan = {
          interfaces = [
            "eth0" "lan1" "lan2" "lan3" "lan4"
          ];
        };
        brguest = {
          interfaces = [
            "eth0.2"
          ];
        };
      };
      interfaces.brlan = {
        ipv4 = {
          addresses = [{
            address = config.cynerd.hosts.spt.mox;
            prefixLength = 24;
          }];
        };
      };
      defaultGateway = config.cynerd.hosts.spt.omnia;
      nameservers = [ config.cynerd.hosts.spt.omnia "1.1.1.1" "8.8.8.8" ];
      dhcpcd.allowInterfaces = [ "brlan" ];
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users = {
            cynerd = {
              acl = ["readwrite #"];
              passwordFile = "/run/secrets/mosquitto.cynerd.pass";
            };
            bigclown = {
              acl = ["readwrite bigclown/#"];
              passwordFile = "/run/secrets/mosquitto.bigclown.pass";
            };
          };
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [1883];

    services.bigclown = {
      gateway = {
        enable = true;
        device = "/dev/ttyUSB0";
        environmentFile = "/run/secrets/bigclown.env";
        baseTopicPrefix = "bigclown/";
        mqtt = {
          username = "bigclown";
          password = "@PASS_MQTT@";
        };
      };
      mqtt2influxdb = {
        enable = true;
        environmentFile = "/run/secrets/bigclown.env";
        mqtt = {
          username = "bigclown";
          password = "@PASS_MQTT@";
        };
        influxdb = {
          host = "cynerd.cz";
          database = "bigclown";
          username = "bigclown";
          password = "@PASS_INFLUXDB@";
          ssl = true;
          verify_ssl = false;
        };
        points = [
          {
            measurement = "temperature";
            topic = "bigclown/node/+/thermometer/+/temperature";
            fields.value = "$.payload";
            tags = {
              id = "$.topic[2]";
              channel = "$.topic[4]";
            };
          }
          {
            measurement = "relative-humidity";
            topic = "bigclown/node/+/hygrometer/+/relative-humidity";
            fields.value = "$.payload";
            tags = {
              id = "$.topic[2]";
              channel = "$.topic[4]";
            };
          }
          {
            measurement = "illuminance";
            topic = "bigclown/node/+/lux-meter/0:0/illuminance";
            fields.value = "$.payload";
            tags = {
              id = "$.topic[2]";
            };
          }
          {
            measurement = "pressure";
            topic = "bigclown/node/+/barometer/0:0/pressure";
            fields.value = "$.payload";
            tags = {
              id = "$.topic[2]";
            };
          }
          {
            measurement = "voltage";
            topic = "bigclown/node/+/battery/+/voltage";
            fields.value = "$.payload";
            tags = {
              id = "$.topic[2]";
            };
          }
          {
            measurement = "button";
            topic = "bigclown/node/+/push-button/+/event-count";
            fields.value = "$.payload";
            tags = {
              id = "$.topic[2]";
              channel = "$.topic[4]";
            };
          }
        ];
      };
    };

    systemd.services.bigclown-leds = {
      description = "Bigclown LEDs control";
      wantedBy = ["multi-user.target"];
      after = ["mosquitto.service"];
      serviceConfig.ExecStart = "${pkgs.bigclown-leds}/bin/bigclown-leds /run/secrets/bigclown-leds.ini";
    };

  };

}
