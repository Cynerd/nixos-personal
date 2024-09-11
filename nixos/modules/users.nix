{
  pkgs,
  config,
  ...
}: let
  isNative = config.nixpkgs.hostPlatform == config.nixpkgs.buildPlatform;
  isArm = config.nixpkgs.hostPlatform.isAarch;
in {
  users = {
    mutableUsers = false;
    groups.cynerd.gid = 1000;
    users = {
      root = {
        hashedPasswordFile = "/run/secrets/root.pass";
      };
      cynerd = {
        group = "cynerd";
        extraGroups = ["users" "wheel" "video" "dialout" "kvm" "uucp" "wireshark" "leds"];
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
        hashedPasswordFile = "/run/secrets/cynerd.pass";
        openssh.authorizedKeys.keyFiles = [
          (config.personal-secrets + "/unencrypted/git-private.pub")
        ];
      };
    };
  };

  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = ["ALL"];
    }
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs = {
    zsh = {
      enable = isNative;
      syntaxHighlighting.enable = isNative;
    };
    shellrc = true;
    vim = {
      enable = isArm;
      defaultEditor = isArm;
    };
    neovim = {
      enable = !isArm;
      defaultEditor = !isArm;
      withNodeJs = true;
    };

    wireshark.enable = true;
  };

  programs.fuse.userAllowOther = true;
}
