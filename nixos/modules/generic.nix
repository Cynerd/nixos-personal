{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    system.stateVersion = "22.05";

    nix = {
      extraOptions = "experimental-features = nix-command flakes";
      settings = {
        auto-optimise-store = true;
        substituters = [
          "https://cache.nixos.org"
          "https://thefloweringash-armv7.cachix.org"
          "https://arm.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso="
          "arm.cachix.org-1:K3XjAeWPgWkFtSS9ge5LJSLw3xgnNqyOaG7MDecmTQ8="
        ];
      };
      registry = {
        personal.to = {
          type = "git";
          url = "https://git.cynerd.cz/nixos-personal";
        };
      };
    };

    boot.loader.systemd-boot.enable = mkOverride 1100 true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = ["boot.shell_on_fail"];
    hardware.enableAllFirmware = true;


    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      git # We need git for this repository to even work
      # Administration tools
      coreutils moreutils binutils psmisc progress lshw file
      ldns wget
      gnumake
      exfat exfatprogs
      nix-index
      usbutils

      # NCurses tools
      htop iotop glances
      mc
      screen tmux
      ncdu

      # ls tools
      tree
      mlocate
      lsof
      strace

      sourceHighlight # Colors for less
      unrar p7zip zip unzip

      # Network
      nmap netcat traceroute
      iftop nethogs
      # TODO add mdns
      sshfs

      lm_sensors

    ] ++ optional (system == "x86_64-linux") ltrace;

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
        subUidRanges = [{ count = 65534; startUid = 10000; }];
        subGidRanges = [{ count = 65534; startGid = 10000; }];
        isNormalUser = true;
        createHome = true;
        shell = pkgs.zsh.out;
        passwordFile = "/run/secrets/cynerd.pass";
        openssh.authorizedKeys.keyFiles = [
          (config.personal-secrets + "/unencrypted/git-private.pub")
        ];
      };
    };
    programs.zsh.enable = true;
    programs.shellrc.enable = true;
    programs.vim.defaultEditor = mkDefault true;

    security.sudo.extraRules = [
      { groups = [ "wheel" ]; commands = [ "ALL" ]; }
    ];

    services.openssh.enable = true;

    time.timeZone = "Europe/Prague";
    i18n.defaultLocale = "en_US.UTF-8";
  };

}
