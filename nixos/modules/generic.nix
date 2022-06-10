{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    system.stateVersion = "22.05";

    nix = {
      extraOptions = "experimental-features = nix-command flakes";
      autoOptimiseStore = true;
      registry = {
        personal.to = {
          type = "git";
          url = "https://git.cynerd.cz/nixos-personal";
        };
      };
    };

    boot.loader.systemd-boot.enable = mkDefault true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = ["boot.shell_on_fail"];
    hardware.enableAllFirmware = true;


    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      git # We need git for this repository to even work
      # Administration tools
      coreutils moreutils psmisc progress lshw
      dig
      gnumake

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
      unrar p7zip

      # Vim plugins (used for root account)
      vimPlugins.vim-nix
      vimPlugins.vim-nftables

      # Network
      nmap netcat traceroute
      iftop nethogs
      # TODO add mdns

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
        extraGroups = ["users" "wheel"];
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
