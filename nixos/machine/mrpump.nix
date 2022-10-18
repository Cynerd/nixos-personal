self: { config, lib, pkgs, ... }:

with builtins;
with lib;

{

  config = let

    localNix = import (self.inputs.nix.outPath + "/docker.nix") {
      pkgs = pkgs;
      name = "local/nix";
      tag = "latest";
      bundleNixpkgs = false;
      nixConf = {
        cores = "0";
        experimental-features = [ "nix-command" "flakes" ];
      };
    };
    localNixDaemon = pkgs.dockerTools.buildLayeredImage {
      fromImage = localNix;
      name = "local/nix-daemon";
      tag = "latest";
      config = {
        Volumes = {
          "/nix/store" = { };
          "/nix/var/nix/db" = { };
          "/nix/var/nix/daemon-socket" = { };
        };
      };
      maxLayers = 125;
    };

  in {

    # Docker for the gitlab runner
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "daily";
      };
    };
    users.users.cynerd.extraGroups = [ "docker" ];

    # Common container for the Gitlab Nix runner
    virtualisation.oci-containers = {
      backend = "docker";
      containers.gitlabnix = {
        imageFile = localNixDaemon;
        image = "local/nix-daemon:latest";
        cmd = ["nix" "daemon"];
      };
    };

    # Gitlab runner
    systemd.services.gitlab-runner.serviceConfig = let
      config = (pkgs.formats.toml{}).generate "gitlab-runner.toml" {
        concurent = 1;
        session_server = {
          session_timeout = 1800;
        };
        runners = [
          {
            name = "MrPump Docker (LogC)";
            url = "https://gitlab.com";
            id = 18138767;
            token = "@TOKEN_LOGC_DOCKER@";
            executor = "docker";
            docker = {
              image = "alpine";
            };
          }
          {
            name = "MrPump Nix (LogC)";
            url = "https://gitlab.com";
            id = 18139391;
            token = "@TOKEN_LOGC_NIX@";
            executor = "docker";
            docker = {
              image = "local/nix:latest";
              allowed_images = ["local/nix:latest"];
              pull_policy = "never";
              allowed_pull_policies = ["never"];
              volumes_from = ["gitlabnix:ro"];
            };
            environment = [
              "NIX_REMOTE=daemon"
              "ENV=/etc/profile.d/nix-daemon.sh"
              "BASH_ENV=/etc/profile.d/nix-daemon.sh"
            ];
            # TODO for some reason the /tmp seems to be missing
            pre_build_script = ''
              mkdir -p /tmp
            '';
          }
        ];
      };
      configPath = "$HOME/.gitlab-runner/config.toml";
      configureScript = pkgs.writeShellScript "gitlab-runner-configure" ''
        docker load < ${localNix}
        mkdir -p $(dirname ${configPath})
        ${pkgs.gawk}/bin/awk '{
          for(varname in ENVIRON)
            gsub("@"varname"@", ENVIRON[varname])
          print
        }' "${config}" > "${configPath}"
        chown -R --reference=$HOME $(dirname ${configPath})
      '';
    in {
      EnvironmentFile = "/run/secrets/gitlab-runner.env";
      ExecStartPre = mkForce "!${configureScript}";
      ExecReload = mkForce "!${configureScript}";
    };
    services.gitlab-runner.enable = true;

  };

}
