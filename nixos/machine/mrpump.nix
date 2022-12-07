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
      extraPkgs = with pkgs; [ cachix ];
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
        concurrent = 1;
        runners = [
          {
            name = "MrPump Docker";
            url = "https://gitlab.com";
            id = 18138767;
            token = "@TOKEN_DOCKER@";
            executor = "docker";
            docker = {
              image = "alpine";
            };
          }
          {
            name = "MrPump Nix";
            url = "https://gitlab.com";
            id = 18139391;
            token = "@TOKEN_NIX@";
            executor = "docker";
            docker = {
              image = "local/nix:latest";
              allowed_images = ["local/nix:latest"];
              pull_policy = "if-not-present";
              allowed_pull_policies = ["if-not-present"];
              volumes_from = ["gitlabnix:ro"];
            };
            environment = [
              "NIX_REMOTE=daemon"
              "ENV=/etc/profile.d/nix-daemon.sh"
              "BASH_ENV=/etc/profile.d/nix-daemon.sh"
            ];
            # TODO for some reason the /tmp seems to be missing
            # The cp is required to allow modification of nix config for cachix as
            # otherwise it is link to the read only file in the store.
            pre_build_script = ''
              mkdir -p /tmp
              cp --remove-destination \
                $(readlink -f /etc/nix/nix.conf) /etc/nix/nix.conf
            '';
          }
        ];
      };
      configPath = "$HOME/.gitlab-runner/config.toml";
      configureScript = pkgs.writeShellScript "gitlab-runner-configure" ''
        ${pkgs.docker}/bin/docker load < ${localNix}
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
