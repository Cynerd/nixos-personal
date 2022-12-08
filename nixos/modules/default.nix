nixpkgs: {
  cynerd-autounlock = import ./autounlock.nix;
  cynerd-compile = import ./compile.nix;
  cynerd-desktop = import ./desktop.nix;
  cynerd-develop = import ./develop.nix nixpkgs;
  cynerd-gaming = import ./gaming.nix;
  cynerd-generic = import ./generic.nix;
  cynerd-hosts = import ./hosts.nix;
  cynerd-openvpn = import ./openvpn.nix;
  cynerd-syncthing = import ./syncthing.nix;
  cynerd-wifi-client = import ./wifi-client.nix;
}
