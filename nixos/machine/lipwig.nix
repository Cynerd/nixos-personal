{
  config,
  pkgs,
  ...
}: {
  deploy = {
    enable = true;
    ssh.host = "cynerd.cz";
  };

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
      "cloud.cynerd.cz" = {
        forceSSL = true;
        useACMEHost = "cynerd.cz";
      };
      "grafana.cynerd.cz" = {
        forceSSL = true;
        useACMEHost = "cynerd.cz";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}/";
          extraConfig = "proxy_set_header Host $host;";
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
      "cloud.cynerd.cz"
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

  # Nextcloud ################################################################
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    https = true;
    hostName = "cloud.cynerd.cz";
    datadir = "/nas/nextcloud";
    config = {
      adminuser = "cynerd";
      adminpassFile = "/run/secrets/nextcloud.admin.pass";
      dbtype = "pgsql";
      dbhost = "/run/postgresql";
      dbtableprefix = "oc_";
    };
    settings = {
      #log_type = "systemd";
      default_phone_region = "CZ";
    };
    phpExtraExtensions = php: [php.pgsql php.pdo_pgsql];
    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
    };
    maxUploadSize = "1G";
    appstoreEnable = false;
    extraApps = {
      inherit
        (config.services.nextcloud.package.packages.apps)
        bookmarks
        calendar
        contacts
        cookbook
        deck
        forms
        groupfolders
        impersonate
        maps
        memories
        notes
        phonetrack
        previewgenerator
        spreed
        tasks
        twofactor_nextcloud_notification
        twofactor_webauthn
        ;
      # Additional modules can be fetched with:
      # NEXTCLOUD_VERSIONS=28 nix run nixpkgs#nc4nix -- -apps "passwords,integration_homeassistant,integration_github,integration_gitlab"
      passwords = pkgs.fetchNextcloudApp {
        url = "https://git.mdns.eu/api/v4/projects/45/packages/generic/passwords/2024.2.0/passwords.tar.gz";
        sha256 = "0s5z6pxkcwmhlbzy9s2g0s05n1iqjmxr2jqxz7ayklin9kcgr3h7";
        license = "agpl3";
      };
      integration_github = pkgs.fetchNextcloudApp {
        url = "https://github.com/nextcloud-releases/integration_github/releases/download/v2.0.6/integration_github-v2.0.6.tar.gz";
        sha256 = "0rjdlsalayb21nmh3j5bl42dcbavxka2r5g9csagz7vc9dl0qrw6";
        license = "agpl3";
      };
      integration_gitlab = pkgs.fetchNextcloudApp {
        url = "https://github.com/nextcloud-releases/integration_gitlab/releases/download/v1.0.18/integration_gitlab-v1.0.18.tar.gz";
        sha256 = "13vlbr7sigqrh480a9zp7zl9nbzb4pk8m1zzlqv9lkzj3zywp7mi";
        license = "agpl3";
      };
    };
  };
  environment.systemPackages = with pkgs; [exiftool ffmpeg-headless nodejs];

  # Postgresql ###############################################################
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["nextcloud"];
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
}
