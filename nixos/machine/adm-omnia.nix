{ config, lib, pkgs, ... }:

with lib;

{

  config = {
    cynerd = {
      openvpn.oldpersonal = true;
    };

  };

}
