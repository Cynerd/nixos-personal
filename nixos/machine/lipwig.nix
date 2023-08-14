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
        enable = false;
        baseDir = "/nas";
      };
      openvpn.oldpersonal = true;
    };

    fileSystems."/nas" = {
      device = "172.16.128.63:/nas/2682";
      fsType = "nfs";
    };

    networking.firewall = {
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [1194];
    };

    # Web ######################################################################
    services.nginx = {
      enable = true;
      virtualHosts = {
        "cynerd.cz" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/".root = ../../web;
            "/radicale/" = {
              proxyPass = "http://127.0.0.1:5232/";
              extraConfig = ''
                proxy_set_header  X-Script-Name /radicale;
                proxy_pass_header Authorization;
              '';
            };
          };
        };
        "git.cynerd.cz" = {
          forceSSL = true;
          useACMEHost = "cynerd.cz";
          root = "${pkgs.cgit}/cgit";
          locations."/".tryFiles = "$uri @cgit";
          locations."@cgit".extraConfig = ''
            fastcgi_param SCRIPT_FILENAME ${pkgs.cgit}/cgit/cgit.cgi;
            fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
            fastcgi_param PATH_INFO    $uri;
            fastcgi_param QUERY_STRING $args;
            fastcgi_param HTTP_HOST    $server_name;
          '';
        };
        "grafana.cynerd.cz" = {
          forceSSL = true;
          useACMEHost = "cynerd.cz";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}/";
            proxyWebsockets = true;
          };
        };
      };
    };
    services.fcgiwrap = {
      enable = true;
      inherit (config.services.nginx) group;
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "cynerd+acme@email.cz";
      certs."cynerd.cz".extraDomainNames = [
        "git.cynerd.cz"
        "grafana.cynerd.cz"
      ];
    };

    # Git ######################################################################
    services.gitolite = {
      enable = true;
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
    environment.etc."cgitrc".text = ''
      root-title=Cynerd's git repository
      root-desc=All my projects (at least those released to public)
      #logo=cynerd.cz/wolf.svg
      virtual-root=/

      # Allow download of tar.gz, tar.bz2 and zip-files
      snapshots=tar.gz tar.bz2 zip
      ## List of common mimetypes
      mimetype.gif=image/gif
      mimetype.html=text/html
      mimetype.jpg=image/jpeg
      mimetype.jpeg=image/jpeg
      mimetype.pdf=application/pdf
      mimetype.png=image/png
      mimetype.svg=image/svg+xml

      source-filter=${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py
      about-filter=${pkgs.cgit}/lib/cgit/filters/about-formatting.sh

      readme=:README.md
      readme=:README.adoc

      enable-index-owner=0
      enable-index-links=1
      enable-http-clone=1
      clone-url=https://git.cynerd.cz/$CGIT_REPO_URL git://cynerd.cz/$CGIT_REPO_URL.git git@cynerd.cz:$CGIT_REPO_URL
      enable-commit-graph=1
      branch-sort=age

      remove-suffix=1
      enable-git-config=1
      project-list=/var/lib/git/projects.list
      scan-path=/var/lib/git/repositories/
    '';

    # CalDAV and CardDAV #######################################################
    # TODO vdirsyncer needs CA
    services.radicale = {
      enable = true;
      rights.cynerd = {
        user = "cynerd";
        collection = ".*";
        permission = "rw";
      };
      settings = {
        server.hosts = ["0.0.0.0:5232" "[::]:5232"];
        encoding = {
          request = "utf-8";
          stock = "utf-8";
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "${config.personal-secrets}/unencrypted/radicale.users";
          htpasswd_encryption = "bcrypt";
          delay = 1;
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/";
        };
        web.type = "none";
      };
    };

    # Old Syncthing ############################################################
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;

      overrideDevices = false;
      overrideFolders = false;

      dataDir = "/nas/sync";
      configDir = "/nas/sync/.syncthing";
    };
  };
}
