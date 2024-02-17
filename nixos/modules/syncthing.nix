{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) filterAttrs mkOption types mkIf any mkDefault recursiveUpdate genAttrs;
  cnf = config.cynerd.syncthing;
  inherit (config.networking) hostName;
  allDevices = [
    "albert"
    "binky"
    "errol"
    "lipwig"
    "ridcully"
    "spt-omnia"
  ];
  mediaDevices = [
    "lipwig"
    "binky"
    "errol"
    "ridcully"
    "spt-omnia"
  ];
  bigStorageDevices = [
    "errol"
    "ridcully"
    "spt-omnia"
  ];
  filterDevice = filterAttrs (n: v: any (d: d == hostName) v.devices);
in {
  options = {
    cynerd.syncthing = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "My personal Syncthing configuration";
      };

      baseDir = mkOption {
        type = types.str;
        default = "/home/cynerd";
        description = "Base directory for all folders being synced.";
      };
    };
  };

  config = mkIf cnf.enable {
    services.syncthing = {
      enable = any (n: n == hostName) allDevices;
      user = mkDefault "cynerd";
      key = "/run/secrets/syncthing.key.pem";
      cert = "/run/secrets/syncthing.cert.pem";

      openDefaultPorts = true;

      overrideFolders = true;
      folders = filterDevice {
        "${cnf.baseDir}/documents" = {
          label = "Documents";
          id = "documents";
          devices = allDevices;
          ignorePerms = false;
        };
        "${cnf.baseDir}/notes" = {
          label = "Notes";
          id = "notes";
          devices = allDevices;
          ignorePerms = false;
        };
        "${cnf.baseDir}/projects" = {
          label = "Projects";
          id = "projects";
          devices = allDevices;
          ignorePerms = false;
        };
        "${cnf.baseDir}/pictures" = {
          label = "Pictures";
          id = "pictures";
          devices = mediaDevices;
          ignorePerms = false;
        };
        # TODO phone-photos
        "${cnf.baseDir}/music/primary" = {
          label = "Music-primary";
          id = "music-primary";
          devices = mediaDevices;
          ignorePerms = false;
        };
        "${cnf.baseDir}/music/secondary" = {
          label = "Music-secondary";
          id = "music-secondary";
          devices = bigStorageDevices;
          ignorePerms = false;
        };
        "${cnf.baseDir}/music/flac" = {
          label = "Music-flac";
          id = "music-flac";
          devices = bigStorageDevices;
          ignorePerms = false;
        };
        "${cnf.baseDir}/video" = {
          label = "Video";
          id = "video";
          devices = bigStorageDevices;
          ignorePerms = false;
        };
      };

      overrideDevices = true;
      devices =
        recursiveUpdate
        (genAttrs allDevices (name: {
          id = config.secrets.syncthingIDs."${name}";
        }))
        {
          lipwig.addresses = ["tcp://cynerd.cz"];
        };
      # TODO phone
    };
  };
}
