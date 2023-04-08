{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  isNative = config.nixpkgs.hostPlatform == config.nixpkgs.buildPlatform;
in {
  config = {
    system.stateVersion = "22.05";

    nix = {
      extraOptions = "experimental-features = nix-command flakes";
      settings = {
        auto-optimise-store = true;
        substituters = [
          "https://thefloweringash-armv7.cachix.org"
          "https://arm.cachix.org"
        ];
        trusted-public-keys = [
          "thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso="
          "arm.cachix.org-1:K3XjAeWPgWkFtSS9ge5LJSLw3xgnNqyOaG7MDecmTQ8="
        ];
        trusted-users = ["@wheel"];
      };
      registry = {
        personal.to = {
          type = "git";
          url = "https://git.cynerd.cz/nixos-personal";
        };
      };
    };

    boot.loader.systemd-boot.enable = mkOverride 1100 true;
    boot.loader.efi.canTouchEfiVariables = mkDefault true;
    boot.kernelPackages = mkOverride 1100 pkgs.linuxPackages_latest;
    boot.kernelParams = ["boot.shell_on_fail"];
    hardware.enableAllFirmware = true;
    services.fwupd.enable = mkIf (pkgs.system == "x86_64-linux") true;

    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs;
      [
        git # We need git for this repository to even work
        # Administration tools
        coreutils
        binutils
        psmisc
        progress
        lshw
        file
        vde2
        ldns
        wget
        gnumake
        exfat
        exfatprogs
        ntfs3g
        nix-index
        usbutils
        pciutils
        smartmontools

        # NCurses tools
        htop
        iotop
        mc
        screen
        tmux
        pv

        # ls tools
        tree
        lsof
        strace

        sourceHighlight # Colors for less
        unrar
        p7zip
        zip
        unzip

        # Network
        nmap
        netcat
        traceroute
        iftop
        nethogs
        sshfs
        wakeonlan
        speedtest-cli
        librespeed-cli

        lm_sensors
      ]
      ++ optionals (system == "x86_64-linux") [
        ltrace
      ]
      ++ optionals (!isNative) [
        ncdu_1
      ]
      ++ optionals isNative [
        moreutils
        glances
        ncdu
        mlocate
      ];

    users.mutableUsers = false;
    users.groups.cynerd.gid = 1000;
    users.users = {
      root = {
        passwordFile = "/run/secrets/root.pass";
      };
      cynerd = {
        group = "cynerd";
        extraGroups = ["users" "wheel" "dialout" "kvm" "uucp"];
        uid = 1000;
        subUidRanges = [
          {
            count = 65534;
            startUid = 10000;
          }
        ];
        subGidRanges = [
          {
            count = 65534;
            startGid = 10000;
          }
        ];
        isNormalUser = true;
        createHome = true;
        shell =
          if isNative
          then pkgs.zsh.out
          else pkgs.bash.out;
        passwordFile = "/run/secrets/cynerd.pass";
        openssh.authorizedKeys.keyFiles = [
          (config.personal-secrets + "/unencrypted/git-private.pub")
        ];
      };
    };
    programs.zsh = {
      enable = isNative;
      syntaxHighlighting.enable = isNative;
    };
    programs.shellrc = true;
    programs.vim.defaultEditor = mkDefault true;

    security.sudo.extraRules = [
      {
        groups = ["wheel"];
        commands = ["ALL"];
      }
    ];
    networking.dhcpcd.extraConfig = "controlgroup wheel";
    environment.etc."dhcpcd.conf".text = "controlgroup wheel";

    services.openssh.enable = true;

    time.timeZone = "Europe/Prague";
    i18n.defaultLocale = "en_US.UTF-8";

    services.udev.packages = [
      (pkgs.writeTextFile rec {
        name = "bfq-drives.rules";
        destination = "/etc/udev/rules.d/60-${name}";
        text = ''
          ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/scheduler}="bfq"
          ACTION=="add|change", KERNEL=="nvme*n[0-9]", ATTR{queue/scheduler}="bfq"
        '';
      })
    ];

    system.extraSystemBuilderCmds = ''
      substituteAll ${./nixos-system.sh} $out/bin/nixos-system
      chmod +x $out/bin/nixos-system
    '';

    programs.fuse.userAllowOther = true;
  };
}
