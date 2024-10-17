{
  config,
  lib,
  ...
}: let
  inherit (builtins) elem readFile readDir;
  inherit (lib) mkOption types mkIf hasSuffix removeSuffix hasAttr filterAttrs mapAttrs mapAttrs' nameValuePair mergeAttrsList recursiveUpdate;

  servers = ["ridcully"]; # TODO "errol"
  clients =
    mapAttrs' (fname: _:
      nameValuePair (removeSuffix ".pub" fname)
      (readFile (config.personal-secrets + "/unencrypted/backup/${fname}")))
    (filterAttrs (n: v: v == "regular" && hasSuffix ".pub" n)
      (readDir (config.personal-secrets + "/unencrypted/backup")));
  edpersonal = readFile (config.personal-secrets + "/unencrypted/edpersonal.pub");
in {
  options.cynerd = {
    borgjobs = mkOption {
      type = with types; attrsOf anything;
      description = "Job to be backed up for this ";
    };
  };

  config = {
    services.borgbackup = {
      repos = mkIf (elem config.networking.hostName servers) (
        mapAttrs (name: key: {
          path = "/back/${name}";
          authorizedKeys = [key edpersonal];
          allowSubRepos = true;
        })
        clients
      );

      jobs = mkIf (hasAttr config.networking.hostName clients) (mergeAttrsList
        (map (server: (mapAttrs' (n: v:
            nameValuePair "${server}-${n}"
            (recursiveUpdate
              (recursiveUpdate {
                  encryption.mode = "none";
                  prune = {
                    keep = {
                      daily = 7;
                      weekly = 4;
                      monthly = -1;
                    };
                    prefix = n;
                  };
                }
                v)
              {
                repo = "borg@${server}:./${n}";
                environment = {
                  BORG_RSH = "ssh -i /run/secrets/borgbackup.key";
                };
                archiveBaseName = null;
              }))
          config.cynerd.borgjobs))
          servers));
    };
  };
}
