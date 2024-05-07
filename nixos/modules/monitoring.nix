{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkMerge mkIf optionalAttrs optionals;
  cnf = config.cynerd.monitoring;
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
    drives = mkOption {
      type = types.bool;
      default = true;
      description = "If S.M.A.R.T. should be enabled";
    };
    speedtest = mkOption {
      type = types.bool;
      default = false;
      description = "If speedtest should be used to measure connection speed";
    };
  };

  config = mkMerge [
    (mkIf cnf.enable {
      # Telegraf configuration
      services.telegraf = {
        enable = true;
        package = pkgs.writeShellScriptBin "telegraf" ''
          exec /run/wrappers/bin/telegraf "$@"
        '';
        environmentFiles = ["/run/secrets/telegraf.env"];
        extraConfig = {
          agent = {};
          outputs.influxdb_v2 = [
            {
              urls = ["http://cynerd.cz:8086"];
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
              net = [{ignore_protocol_stats = false;}];
              nstat = [{}];
              system = [{}];
              processes = [{}];
              systemd_units = [{}];
              wireguard = [{}];
            }
            // (optionalAttrs cnf.drives {
              smart = [
                {
                  path_smartctl = "${pkgs.smartmontools}/bin/smartctl";
                  use_sudo = true;
                }
              ];
            })
            // (optionalAttrs cnf.hw {
              sensors = [{}];
              wireless = [{}];
            })
            // (optionalAttrs cnf.speedtest {
              exec = [
                {
                  commands = ["${pkgs.speedtest-cli}/bin/speedtest --json"];
                  name_override = "speedtest";
                  timeout = "5m";
                  interval = "15m";
                  data_format = "json";
                }
              ];
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

      security.wrappers.telegraf = {
        owner = "root";
        group = "root";
        capabilities = "CAP_NET_ADMIN+epi";
        source = "${pkgs.telegraf}/bin/telegraf";
      };
    })

    (mkIf (config.networking.hostName == "lipwig") {
      # InfluxDB
      services = {
        influxdb2.enable = true;
        telegraf.extraConfig.inputs.prometheus = {
          urls = ["http://localhost:8086/metrics"];
        };
        # Grafana
        grafana = {
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
      };
      networking.firewall.allowedTCPPorts = [8086 3000];
    })
  ];
}
