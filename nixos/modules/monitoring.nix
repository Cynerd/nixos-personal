{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
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
    {cynerd.monitoring.host = "errol";}

    (mkIf cnf.enable {
      # Telegraf configuration
      services.telegraf = {
        enable = true;
        environmentFiles = ["/run/secrets/telegraf.env"];
        extraConfig = {
          agent = {};
          outputs.influxdb_v2 = [
            {
              urls = ["http://errol:8086"];
              token = "$INFLUX_TOKEN";
              organization = "personal";
              bucket = "monitoring";
              tagdrop.source = ["bigclown"]; # See home-assistant.nix
            }
          ];
          inputs =
            {
              cpu = [
                {
                  percpu = true;
                  totalcpu = true;
                }
              ];
              mem = [{}];
              swap = [{}];
              disk = [
                {
                  ignore_fs = [
                    "tmpfs"
                    "devtmpfs"
                    "devfs"
                    "iso9660"
                    "overlay"
                    "aufs"
                    "squashfs"
                  ];
                }
              ];
              diskio = [{}];
              net = [{}];
              system = [{}];
              processes = [{}];
              systemd_units = [{}];
              wireguard = [{}];
            }
            // (optionalAttrs cnf.hw {
              sensors = [{}];
              smart = [
                {
                  path_smartctl = "${pkgs.smartmontools}/bin/smartctl";
                  use_sudo = true;
                }
              ];
              wireless = [{}];
            });
        };
      };
      systemd.services.telegraf.path = with pkgs;
        [
          "/run/wrappers"
        ]
        ++ (optionals cnf.hw [
          lm_sensors
          smartmontools
          nvme-cli
        ]);
      security.sudo.extraRules = [
        {
          users = ["telegraf"];
          commands = [
            {
              command = "${pkgs.smartmontools}/bin/smartctl";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    })

    (mkIf isHost {
      # InfluxDB
      services.influxdb2.enable = mkIf isHost true;
      services.telegraf.extraConfig.inputs.prometheus = {
        urls = ["http://localhost:8086/metrics"];
      };
      # Grafana
      services.grafana = mkIf isHost {
        enable = true;
        settings = {
          users.allow_sign_up = false;
          security = {
            admin_user = "cynerd";
            admin_password = "$__file{/run/secrets/grafana.admin.pass}";
          };
          server = {
            http_addr = "";
            http_port = 3000;
          };
        };
      };
      networking.firewall.allowedTCPPorts = [8086 3000];
    })
  ];
}
