{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
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
            telegraf = {
              acl = ["read bigclown/node/#"];
              passwordFile = "/run/secrets/mosquitto.telegraf.pass";
            };
            homeassistant = {
              acl = [
                "readwrite homeassistant/#"
                "readwrite bigclown/#"
                "readwrite zigbee2mqtt/#"
              ];
              passwordFile = "/run/secrets/mosquitto.homeassistant.pass";
            };
            bigclown = {
              acl = ["readwrite bigclown/#"];
              passwordFile = "/run/secrets/mosquitto.bigclown.pass";
            };
            zigbee2mqtt = {
              acl = [
                "readwrite homeassistant/#"
                "readwrite zigbee2mqtt/#"
              ];
              passwordFile = "/run/secrets/mosquitto.zigbee2mqtt.pass";
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
    };

    systemd.services.bigclown-leds = {
      description = "Bigclown LEDs control";
      wantedBy = ["multi-user.target"];
      wants = ["mosquitto.service"];
      serviceConfig.ExecStart = "${pkgs.bigclown-leds}/bin/bigclown-leds /run/secrets/bigclown-leds.ini";
    };

    services.telegraf.extraConfig = {
      outputs.influxdb_v2 = [
        {
          urls = ["http://errol:8086"];
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
    systemd.services.telegraf.wants = ["mosquitto.service"];

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
          sensor = import ./home-assistant/sensors.nix;
          light = import ./home-assistant/light.nix;
        };
        default_config = {};
        automation = "!include automations.yaml";
      };
      extraComponents = ["met"];
      package = pkgs.home-assistant.override {
        extraPackages = pkgs:
          with pkgs; [
            securetar
            pyipp
          ];
        packageOverrides = self: super: {
          scapy = super.scapy.override {
            withPlottingSupport = false;
          };
          s3transfer = super.s3transfer.overridePythonAttrs (oldAttrs: {
            dontUsePytestCheck = true;
            dontUseSetuptoolsCheck = true;
          });
        };
      };
    };
  };
}
