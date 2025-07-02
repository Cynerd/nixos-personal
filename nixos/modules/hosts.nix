{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cnf = config.cynerd.hosts;

  staticZoneOption = mkOption {
    type = types.attrsOf types.str;
    readOnly = true;
    description = "The mapping of zone hosts to their IP";
  };
in {
  options = {
    cynerd.hosts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Use my personal static hosts";
      };
      zd = staticZoneOption;
      wg = staticZoneOption;
      spt = staticZoneOption;
      adm = staticZoneOption;
    };
  };

  config = {
    cynerd.hosts = {
      zd = {
        "mox" = "10.8.0.1";
        # Portable
        "binky" = "10.8.0.63";
      };
      wg = {
        "lipwig" = "10.8.1.1";
        # Portable
        "binky" = "10.8.1.10";
        "android" = "10.8.1.30";
        # Endpoints
        "spt-omnia" = "10.8.1.50";
        "adm-omnia" = "10.8.1.51";
        "zd-mox" = "10.8.1.52";
        # Endpoints without routing
        "dean" = "10.8.1.59";
      };
      spt = {
        # Network
        "omnia" = "10.8.2.1";
        "mox" = "10.8.2.2";
        "mox2" = "10.8.2.3";
        # Local
        "mpd" = "10.8.2.51";
        "errol" = "10.8.2.60";
        "printer" = "10.8.2.90";
        # Portable
        "albert" = "10.8.2.61";
        "binky" = "10.8.2.63";
      };
      adm = {
        # Network
        "omnia" = "10.8.3.1";
        "omnia2" = "10.8.3.3";
        # Local
        "ridcully" = "10.8.3.60";
        "3dprint" = "10.8.3.80";
        "mpd" = "10.8.3.51";
        "printer" = "192.168.1.20";
        # Portable
        "albert" = "10.8.3.61";
        "binky" = "10.8.3.63";
      };
    };

    networking.hosts = mkIf cnf.enable {
      # Zd
      "${cnf.zd.mox}" = ["mox.zd"];
      "${cnf.zd.binky}" = ["binky.zd"];
      # Wireguard
      "${cnf.wg.lipwig}" = ["lipwig.wg"];
      "${cnf.wg.binky}" = ["binky.wg"];
      "${cnf.wg.android}" = ["android.wg"];
      "${cnf.wg.spt-omnia}" = ["spt.wg"];
      "${cnf.wg.adm-omnia}" = ["adm.wg"];
      "${cnf.wg.zd-mox}" = ["zd.wg"];
      "${cnf.wg.dean}" = ["dean" "dean.wg"];
      # Spt
      "${cnf.spt.omnia}" = ["omnia.spt"];
      "${cnf.spt.mox}" = ["mox.spt"];
      "${cnf.spt.mox2}" = ["mox2.spt"];
      "10.8.2.4" = ["mi3g.spt"];
      "${cnf.spt.mpd}" = ["mpd.spt"];
      "${cnf.spt.errol}" = ["errol" "desktop.spt"];
      "${cnf.spt.albert}" = ["albert.spt"];
      "${cnf.spt.binky}" = ["binky.spt"];
      # Adm
      "${cnf.adm.omnia}" = ["omnia.adm"];
      "10.8.3.2" = ["redmi.adm"];
      "${cnf.adm.omnia2}" = ["omnia2.adm"];
      "${cnf.adm.ridcully}" = ["ridcully" "desktop.adm"];
      "${cnf.adm.albert}" = ["albert.adm"];
      "${cnf.adm.binky}" = ["binky.adm"];
      "${cnf.adm."3dprint"}" = ["3dprint"];
      "${cnf.adm.mpd}" = ["mpd.adm"];
    };
  };
}
