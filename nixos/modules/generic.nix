{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOverride mkDefault;
in {
  config = {
    system.stateVersion = "24.05";

    nix = {
      extraOptions = "experimental-features = nix-command flakes repl-flake";
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

    boot = {
      loader.systemd-boot.enable = mkOverride 1100 true;
      loader.efi.canTouchEfiVariables = mkDefault true;
      kernelPackages = mkOverride 1100 pkgs.linuxPackages_latest;
      kernelParams = ["boot.shell_on_fail"];
    };
    hardware.enableAllFirmware = true;
    services.fwupd.enable = mkDefault (pkgs.system == "x86_64-linux");
    systemd.oomd.enable = false;

    networking = {
      nftables.enable = true;
      dhcpcd.extraConfig = "controlgroup wheel";
    };

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

    documentation = {
      enable = mkDefault false;
      doc.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };
  };
}
