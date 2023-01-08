{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    cynerd = {
      syncthing = {
        #enable = true;
        baseDir = "/nas";
      };
      openvpn.personal = true;
    };

    fileSystems."/nas" = {
      device = "172.16.128.63:/nas/2682";
      fsType = "nfs";
    };

    # Git ######################################################################
    services.gitolite = {
      enable = false;
      user = "git";
      group = "git";
      dataDir = "/var/lib/git";
      adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaMmBV0wPvG5JQIWxi20IDlLokhRBumTEbUUD9TNWoY Bootstrap gitolite key";
    };
    services.gitDaemon = {
      enable = false;
      user = "gitdemon";
      group = "gitdaemon";
      basePath = "/var/lib/git/repositories";
    };

    # CalDAV and CardDAV #######################################################
    services.radicale = {
      enable = true;
      settings = {
        server = {
          hosts = ["0.0.0.0:5232" "[::]:5232"];
          ssl = true;
          certificate = "/run/secrets/radicale/radicale.crt";
          key = "/run/secrets/radicale/radicale.key";
        };
        encoding = {
          request = "utf-8";
          stock = "utf-8";
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/run/secrets/radicale/users";
          htpasswd_encryption = "bcrypt";
          delay = 1;
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/";
        };
        web = {
          type = "none";
        };
      };
    };
  };
}
