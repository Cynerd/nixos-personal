{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionals;
  isNative = config.nixpkgs.hostPlatform == config.nixpkgs.buildPlatform;
in {
  nixpkgs = {
    config.allowUnfree = true;
    flake = {
      setNixPath = false;
      setFlakeRegistry = false;
    };
  };
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
      usbutils
      pciutils
      smartmontools
      parted

      # NCurses tools
      htop
      btop
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
      netcat
      traceroute
      iftop
      nethogs
      sshfs
      wakeonlan
      speedtest-cli
      librespeed-cli
      #termshark
      w3m

      lm_sensors
    ]
    ++ optionals (system == "x86_64-linux") [
      nmap
      ltrace
    ]
    ++ optionals (!isNative) [
      ncdu_1
    ]
    ++ optionals isNative [
      ncdu
      moreutils
    ];
}
