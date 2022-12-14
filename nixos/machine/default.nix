self: {
  machine-albert = import ./albert.nix;
  machine-binky = import ./binky.nix;
  machine-dean = import ./dean.nix;
  machine-errol = import ./errol.nix;
  machine-ridcully = import ./ridcully.nix;
  machine-susan = import ./susan.nix;

  machine-lipwig = import ./lipwig.nix;
  machine-mrpump = import ./mrpump.nix self;

  machine-gaspode = import ./gaspode.nix;

  machine-spt-omnia = import ./spt-omnia.nix;
  machine-spt-mox = import ./spt-mox.nix;
  machine-spt-mox2 = import ./spt-mox2.nix;
  machine-spt-mpd = import ./spt-mpd.nix;

  machine-adm-omnia = import ./adm-omnia.nix;
  machine-adm-omnia2 = import ./adm-omnia2.nix;
  machine-adm-mpd = import ./adm-mpd.nix;
}
