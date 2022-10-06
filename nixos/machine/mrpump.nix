{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    boot.isContainer = true;
    boot.loader.initScript.enable = true;

    # Gitlab worker
    services.gitlab-runner = {
      enable = true;
      services.docker = {
        registrationConfigFile = "/run/secrets/gitlab-runner-registration";
        executor = "docker";
        tagList = ["docker"];
        runUntagged = true;
        description = "Docker runner";
      };
    };

  };

}
