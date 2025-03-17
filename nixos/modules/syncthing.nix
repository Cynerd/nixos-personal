{
  config,
  lib,
  ...
}: let
  inherit (lib) elem filterAttrs mkIf any mkDefault recursiveUpdate genAttrs;

  allDevices = [
    "binky"
    "errol"
    "lipwig"
    "ridcully"
  ];
  bigStorageDevices = [
    "errol"
    "ridcully"
  ];

  inherit (config.networking) hostName;
  baseDir = config.services.syncthing.dataDir;
  filterDevice = filterAttrs (_: v: any (d: d == hostName) v.devices);
in {
  config = mkIf (config.services.syncthing.enable && elem hostName allDevices) {
    services.syncthing = {
      user = mkDefault "cynerd";
      group = mkDefault "cynerd";

      key = "/run/secrets/syncthing.key.pem";
      cert = "/run/secrets/syncthing.cert.pem";

      openDefaultPorts = true;
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        folders = filterDevice {
          "${baseDir}/documents" = {
            label = "Documents";
            id = "documents";
            devices = allDevices;
            ignorePerms = false;
          };
          "${baseDir}/notes" = {
            label = "Notes";
            id = "notes";
            devices = allDevices;
            ignorePerms = false;
          };
          "${baseDir}/projects" = {
            label = "Projects";
            id = "projects";
            devices = allDevices;
            ignorePerms = false;
          };
          "${baseDir}/elektroline" = {
            label = "Elektroline";
            id = "elektroline";
            devices = allDevices;
            ignorePerms = false;
          };
          "${baseDir}/pictures" = {
            label = "Pictures";
            id = "pictures";
            devices = bigStorageDevices;
            ignorePerms = false;
          };
          "${baseDir}/music" = {
            label = "Music";
            id = "music";
            devices = bigStorageDevices;
            ignorePerms = false;
          };
          "${baseDir}/video" = {
            label = "Video";
            id = "video";
            devices = bigStorageDevices;
            ignorePerms = false;
          };
          "${baseDir}/turris" = {
            label = "Turris";
            id = "turris";
            devices = bigStorageDevices;
            ignorePerms = false;
          };
        };

        devices =
          recursiveUpdate
          (genAttrs allDevices (name: {
            id = config.secrets.syncthingIDs."${name}";
          }))
          {
            lipwig.addresses = ["tcp://cynerd.cz"];
          };
      };
    };
  };
}
