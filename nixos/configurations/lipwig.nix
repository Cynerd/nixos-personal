{
  config,
  pkgs,
  inputModules,
  ...
}: {
  imports = [inputModules.vpsadminos];

  config = {
    system.stateVersion = "24.05";
    nixpkgs.hostPlatform.system = "x86_64-linux";

    deploy = {
      enable = true;
      ssh.host = "cynerd.cz";
    };

    cynerd = {
      monitoring = {
        hw = false;
        drives = false;
      };
      wireguard = true;
      borgjobs = {
        postgresql.dumpCommand = pkgs.writeScript "postgreqsl-backup.sh" ''
          /run/wrappers/bin/sudo -u postgres /run/current-system/sw/bin/pg_dumpall
        '';
        nextcloud_data.paths = "/nas/nextcloud/data";
        sync_data.paths = "/sync";
      };
    };

    boot.loader.systemd-boot.enable = false;

    fileSystems = {
      "/nas" = {
        device = "172.16.128.63:/nas/2682";
        fsType = "nfs";
        options = [
          "_netdev"
          "x-systemd.automount"
        ];
      };
      "/nas/nextcloud-sync" = {
        device = "/sync";
        fsType = "fuse.bindfs";
        options = ["map=syncthing/nextcloud:@syncthing/@nextcloud"];
      };
    };

    networking = {
      useNetworkd = true;
      useDHCP = false;
      firewall = {
        allowedTCPPorts = [80 443];
        allowedUDPPorts = [1194];
        filterForward = true;
        extraForwardRules = ''
          iifname {"wg", "personalvpn"} oifname {"wg", "personalvpn"} accept
        '';
      };
    };
    systemd.network.wait-online.enable = false;
    systemd.services.networking-setup.wantedBy = ["network-online.target"];

    environment.systemPackages = with pkgs; [
      # fileSystems
      bindfs
      # Nextcloud
      exiftool
      ffmpeg-headless
      nodejs
    ];

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
            fastcgi_pass unix:${config.services.fcgiwrap.instances.cgit.socket.address};
            fastcgi_param SCRIPT_FILENAME ${pkgs.cgit}/cgit/cgit.cgi;
            fastcgi_param PATH_INFO    $uri;
            fastcgi_param QUERY_STRING $args;
            fastcgi_param HTTP_HOST    $server_name;
          '';
        };
        "cloud.cynerd.cz" = {
          forceSSL = true;
          useACMEHost = "cynerd.cz";
        };
        "office.cynerd.cz" = {
          forceSSL = true;
          useACMEHost = "cynerd.cz";
        };
        "grafana.cynerd.cz" = {
          forceSSL = true;
          useACMEHost = "cynerd.cz";
          locations."/" = {
            proxyPass = "http://localhost:${toString config.services.grafana.settings.server.http_port}";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };
        "searx.cynerd.cz" = {
          forceSSL = true;
          useACMEHost = "cynerd.cz";
          locations."/".extraConfig = ''
            uwsgi_pass "unix:///run/searx/searx.sock";
            include ${config.services.nginx.package}/conf/uwsgi_params;
          '';
        };
      };
    };
    services.fcgiwrap.instances.cgit = {
      process.user = "git";
      socket = {inherit (config.services.nginx) user group;};
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "cynerd+acme@email.cz";
      certs."cynerd.cz".extraDomainNames = [
        "cloud.cynerd.cz"
        "office.cynerd.cz"
        "git.cynerd.cz"
        "grafana.cynerd.cz"
        "searx.cynerd.cz"
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
      package = pkgs.nextcloud30;
      https = true;
      hostName = "cloud.cynerd.cz";
      datadir = "/nas/nextcloud";
      config = {
        adminuser = "cynerd";
        adminpassFile = "/run/secrets/nextcloud.admin.pass";
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
      };
      settings = {
        #log_type = "systemd";
        default_locale = "CZ";
        default_phone_region = "CZ";
        default_timezone = "Europe/Prague";
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
        ];
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
          onlyoffice
          phonetrack
          previewgenerator
          spreed
          tasks
          twofactor_webauthn
          ;
        # Additional modules can be fetched with:
        # NEXTCLOUD_VERSIONS=30 nix run nixpkgs#nc4nix -- -apps "passwords,money,integration_github,integration_gitlab"
        integration_github = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/integration_github/releases/download/v3.1.1/integration_github-v3.1.1.tar.gz";
          hash = "sha256-nm463H33WyXTJkb7+OSsunARNuSl5nc3uGClgwkVvhM=";
          license = "agpl3Plus";
        };
        integration_gitlab = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/integration_gitlab/releases/download/v3.1.2/integration_gitlab-v3.1.2.tar.gz";
          hash = "sha256-nCH0DqYmr4T856sOU5PhSK6WAHIF9mnYThgytxEbkNA=";
          license = "agpl3Plus";
        };
        money = pkgs.fetchNextcloudApp {
          url = "https://github.com/powerpaul17/nc_money/releases/download/v0.30.0/money.tar.gz";
          hash = "sha256-4gHm6sF9S+1G1naRTr+eR8ZyjCpB3viXTzRCNQFUtF0=";
          license = "agpl3Plus";
        };
        passwords = pkgs.fetchNextcloudApp {
          url = "https://git.mdns.eu/api/v4/projects/45/packages/generic/passwords/2025.4.0/passwords.tar.gz";
          hash = "sha256-lj130UJ2WkDytGuYqofN8WtyPEWR0PSiTGIelRGtIyA=";
          license = "agpl3Plus";
        };
      };
    };
    # OnlyOffice ###############################################################
    services.onlyoffice = {
      enable = true;
      hostname = "office.cynerd.cz";
    };

    # Postgresql ###############################################################
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {name = "cynerd";}
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = ["nextcloud"];
      #extraPlugins = ps: with ps; [timescaledb];
    };

    # SearX ####################################################################
    services.searx = {
      enable = true;
      environmentFile = "/run/secrets/searx.env";
      settings = {
        server.secret_key = "@SEARX_SECRET_KEY@";
        search = {
          autocomplete = "google";
          autocomplete_min = 2;
        };
        ui = {
          query_in_title = true;
          infinite_scroll = true;
          center_alignment = true;
          hotkeys = "vim";
        };
        engines = [
          {
            name = "seznam";
            disabled = false;
          }
          {
            name = "material icons";
            disabled = false;
          }
          {
            name = "svgrepo";
            disabled = false;
          }
          {
            name = "peertube";
            disabled = false;
          }
          {
            name = "lib.rs";
            disabled = false;
          }
          {
            name = "gitlab";
            disabled = false;
          }
          {
            name = "sourcehut";
            disabled = false;
          }
          {
            name = "free software directory";
            disabled = false;
          }
          {
            name = "cppreference";
            disabled = false;
          }
          {
            name = "searchcode code";
            disabled = false;
          }
          {
            name = "imdb";
            disabled = false;
          }
          {
            name = "tmdb";
            disabled = false;
          }
        ];
      };
      runInUwsgi = true;
      uwsgiConfig = {
        socket = "/run/searx/searx.sock";
        chmod-socket = "660";
      };
      redisCreateLocally = true;
    };
    users.groups.searx.members = ["nginx"];

    # Syncthing ################################################################
    services.syncthing = {
      enable = true;
      user = "syncthing";
      group = "syncthing";
      dataDir = "/sync";
    };
  };
}
