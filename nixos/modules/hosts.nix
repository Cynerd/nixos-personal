{ config, lib, pkgs, ... }:

with lib;

let

  cnf = config.cynerd.hosts;

  staticZoneOption = mkOption {
    type = types.attrsOf types.str;
    readOnly = true;
  };

in {

  options = {
    cynerd.hosts = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Use my personal static hosts";
      };
      vpn = staticZoneOption;
      spt = staticZoneOption;
      adm = staticZoneOption;
    };
  };

  config = {
    cynerd.hosts = {
      vpn = {
        "lipwig" = "10.8.0.1";
        "dean" = "10.8.0.4";
        # Portable
        "android" = "10.8.0.2";
        "albert" = "10.8.0.3";
        "susan" = "10.8.0.5";
        "binky" = "10.8.0.6";
        # Endpoints
        "spt-omnia" = "10.8.0.50";
        "adm-omnia" = "10.8.0.51";
      };
      spt = {
        # Network
        "omnia" = "10.8.2.1";
        "mox" = "10.8.2.2";
        "mox2" = "10.8.2.3";
        # Local
        "mpd" = "10.8.2.51";
        "errol" = "10.8.2.60";
        # Portable
        "albert" = "10.8.2.61";
        "susan" = "10.8.2.62";
        "binky" = "10.8.2.63";
      };
      adm = {
        # Network
        "omnia" = "10.8.3.1";
        "omnia2" = "10.8.3.3";
        # Local
        "ridcully" = "10.8.3.60";
        "3dprint" = "10.8.3.80";
        "mpd" = "192.168.0.51";
        # Portable
        "albert" ="10.8.3.61";
        "susan" = "10.8.3.62";
        "binky" = "10.8.3.63";
      };
    };

    networking.hosts = mkIf cnf.enable {
      # VPN
      "${cnf.vpn.lipwig}" = ["lipwig.vpn"];
      "${cnf.vpn.android}" = ["android.vpn"];
      "${cnf.vpn.albert}" = ["albert.vpn"];
      "${cnf.vpn.dean}" = ["dean" "dean.vpn"];
      "${cnf.vpn.susan}" = ["susan.vpn"];
      "${cnf.vpn.binky}" = ["binky.vpn"];
      "${cnf.vpn.spt-omnia}" = ["spt.vpn"];
      "${cnf.vpn.adm-omnia}" = ["adm.vpn"];
      # Spt
      "${cnf.spt.omnia}" = ["omnia.spt"];
      "${cnf.spt.mox}" = ["mox.spt"];
      "${cnf.spt.mox2}" = ["mox2.spt"];
      "10.8.2.4" = ["mi3g.spt"];
      "${cnf.spt.mpd}" = ["mpd.spt"];
      "${cnf.spt.errol}" = ["errol" "desktop.spt"];
      "${cnf.spt.albert}" = ["albert.spt"];
      "${cnf.spt.susan}" = ["susan.spt"];
      "${cnf.spt.binky}" = ["binky.spt"];
      # Adm
      "${cnf.adm.omnia}" = ["omnia.adm"];
      "10.8.3.2" = ["redmi.adm"];
      "${cnf.adm.omnia2}" = ["omnia2.adm"];
      "${cnf.adm.ridcully}" = ["ridcully" "desktop.adm"];
      "${cnf.adm.albert}" = ["albert.adm"];
      "${cnf.adm.susan}" = ["susan.adm"];
      "${cnf.adm.binky}" = ["binky.adm"];
      "${cnf.adm."3dprint"}" = ["3dprint"];
      "${cnf.adm.mpd}" = ["mpd.adm"];
    };
  };

}
