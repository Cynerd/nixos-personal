{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    # Gitlab worker
    services.gitlab-runner = {
      enable = true;
      services.docker = {
        registrationConfigFile = "/run/secrets/gitlab-runner-registration";
        tagList = ["docker"];
        runUntagged = true;
        executor = "docker";
        dockerImage = "alpine";
        description = "Docker runner";
      };
    };

  };

}
