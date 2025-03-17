{
  config,
  lib,
  ...
}: let
  inherit (lib) filterAttrs;
in {
  system.stateVersion = "24.05";

  cynerd.rpi = 3;
  deploy = {
    enable = true;
    ssh.host = "nixos@mpd.adm";
  };

  networking.wireless = {
    enable = true;
    networks = filterAttrs (n: _: n == "Nela") config.secrets.wifiNetworks;
    secretsFile = "/run/secrets/wifi.secrets";
    userControlled.enable = true;
  };

  #services.pipewire = {
  #enable = true;
  #alsa.enable = true;
  #pulse.enable = true;
  #};
  #hardware.pulseaudio = {
  #  enable = true;
  #  systemWide = true;
  #  zeroconf.publish.enable = true;
  #};

  #services.spotifyd = {
  #  enable = true;
  #  settings.global = {
  #    device_name = "Adámkovi";
  #    device = "sysdefault";
  #    mixer = "Master";
  #    bitrate = 320;
  #    cache_path = "/var/cahe/spotify";
  #    no_audio_cache = true;
  #    volume_normalisation = true;
  #    normalisation_pregain = -10;
  #    initial_volume = 60;
  #  };
  #};
}
