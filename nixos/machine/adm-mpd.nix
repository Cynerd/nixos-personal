{
  config,
  lib,
  ...
}: let
  inherit (lib) filterAttrs;
in {
  fileSystems = {
    "/" = {
      device = "/dev/mmcblk0p2";
      options = ["compress=lzo" "subvol=@nix"];
    };
    "/home" = {
      device = "/dev/mmcblk0p2";
      options = ["compress=lzo" "subvol=@home"];
    };
    "/boot" = {
      device = "/dev/mmcblk0p1";
    };
  };

  networking.wireless = {
    enable = true;
    networks = filterAttrs (n: _: n == "Nela") config.secrets.wifiNetworks;
    environmentFile = "/run/secrets/wifi.env";
    userControlled.enable = true;
  };

  #services.pipewire = {
  #enable = true;
  #alsa.enable = true;
  #pulse.enable = true;
  #};
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    zeroconf.publish.enable = true;
  };

  services.spotifyd = {
    enable = true;
    settings.global = {
      device_name = "Adámkovi";
      device = "sysdefault";
      mixer = "Master";
      bitrate = 320;
      cache_path = "/var/cahe/spotify";
      no_audio_cache = true;
      volume_normalisation = true;
      normalisation_pregain = -10;
      initial_volume = 60;
    };
  };
}
