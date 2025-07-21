{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkIf;
  cnf = config.cynerd.ha;
in {
  options.cynerd.ha = {
    enable = mkEnableOption "Home assistant setup on the primary router.";
    domain = mkOption {
      type = with types; str;
      description = "The domain name of the system.";
    };
    extraOptions = mkOption {
      type = with types; listOf str;
      default = [];
      description = "Extra options passed to the container.";
    };
  };

  config = mkIf cnf.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = ["home-assistant:/config" "/run/dbus:/run/dbus:ro"];
        environment.TZ = "Europe/Prague";
        image = "ghcr.io/home-assistant/armv7-homeassistant:stable";
        extraOptions =
          [
            "--privileged"
            "--pull=always"
            "--network=host"
          ]
          ++ cnf.extraOptions;
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cnf.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:8123";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };
      };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "cynerd+acme@email.cz";
      certs."${cnf.domain}" = {};
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
