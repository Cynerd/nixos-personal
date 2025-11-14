{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionals;
  inherit (pkgs.stdenv.hostPlatform) isx86_64;
  isNative = pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform;
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

      # ls tools
      tree
      lsof
      strace
      ripgrep

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
      termshark
      w3m

      lm_sensors
    ]
    ++ optionals isx86_64 [
      nmap
      #ltrace
      pv
      screen
    ]
    ++ optionals (!isNative) [
      ncdu_1
    ]
    ++ optionals isNative [
      ncdu
      moreutils
    ];
}
