{ config, lib, pkgs, ... }:

with lib;

let

cnf = config.cynerd.monitoring;
hostName = config.networking.hostName;
isHost = cnf.host == hostName;

in {
  options.cynerd.monitoring = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "If monitoring should be used";
    };
    hw = mkOption {
      type = types.bool;
      default = true;
      description = "If hardware should be reported";
    };

    host = mkOption {
      type = types.str;
      description = "Host name of the monitoring hosting system";
      readOnly = true;
    };
  };

  config = mkMerge [
    { cynerd.monitoring.host = "errol"; }
    (mkIf cnf.enable {
      # Telegraf configuration
      services.telegraf = {
        enable = true;
        environmentFiles = ["/run/secrets/telegraf.env"];
        extraConfig = {
          agent = {};
          outputs.influxdb_v2 = {
            urls = ["http://errol:8086"];
            token = "$INFLUX_TOKEN";
            organization = "personal";
            bucket = "monitoring";
          };
          inputs = {
            cpu = {
              percpu = true;
              totalcpu = true;
            };
            disk = {
              ignore_fs = [
                "tmpfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs"
              ];
            };
            diskio = {};
            diskio = {};
            mem = {};
            net = {};
            processes = {};
            swap = {};
            system = {};
          } // (optionalAttrs cnf.hw {
            sensors = {};
            smart = {};
          });
        };
      };
      # TODO probably add this to the upstream configuration
      systemd.services.telegraf.path = with pkgs; [
      ] ++ (optionals cnf.hw [
        nvme-cli lm_sensors smartmontools
      ]);
    })
    (mkIf isHost {
      # InfluxDB
      services.influxdb2.enable = mkIf isHost true;
      # Grafana
      services.grafana = mkIf isHost {
        enable = true;
        settings = {
          users.allow_sign_up = false;
          security = {
            admin_user = "cynerd";
            admin_password = "$__file{/run/secrets/grafana.admin.pass}";
          };
        };
      };

    })
  ];
}
