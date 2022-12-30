{ config, lib, pkgs, ... }:

with lib;

let

  cnf = config.cynerd.home-assistant;

in {
  options = {
    cynerd.home-assistant = mkEnableOption "Enable Home Assistant and Bigclown";
  };

  config = mkIf cnf {

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
            homeassistant = {
              acl = [
                "readwrite bigclown/#"
                "readwrite homeassistant/#"
              ];
              passwordFile = "/run/secrets/mosquitto.homeassistant.pass";
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
      wants = ["mosquitto.service"];
      serviceConfig.ExecStart = "${pkgs.bigclown-leds}/bin/bigclown-leds /run/secrets/bigclown-leds.ini";
    };

    services.home-assistant = {
      enable = false;
      openFirewall = true;
      configDir = "/var/lib/hass";
      config = {
        homeassistant = {
          name = "SPT";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          time_zone = "Europe/Prague";
          country = "CZ";
        };
        http.server_port = 8808;
        mqtt = {
          broker = "localhost";
          port = 1883;
          username = "homeassistant";
          password = "!secret mqtt_password";
          sensor = import ./home-assistant/sensors.nix;
          light = import ./home-assistant/light.nix;
        };
        met = {};
        default_config = {};
      };
      extraComponents = [];
      package = pkgs.home-assistant.override {
        extraPackages = pkgs: with pkgs; [
          securetar
        ];
        packageOverrides = (self: super: {
          scapy = super.scapy.override {
            withPlottingSupport = false;
          };
          s3transfer = super.s3transfer.overridePythonAttrs (oldAttrs: {
            dontUsePytestCheck = true;
            dontUseSetuptoolsCheck = true;
          });
        });
      };
    };

  };

}
