{
  system,
  nixpkgs,
  default,
}: let
  pkgs = nixpkgs.legacyPackages.${system};
in
  pkgs.mkShell {
    packages = with pkgs; [
      (python3.withPackages (pypkgs:
        with pypkgs; [
          ipython

          pytest
          pytest-html
          pytest-tap
          coverage
          python-lsp-black
          pylint
          pydocstyle
          mypy

          pygraphviz
          matplotlib

          python-gitlab
          PyGithub

          schema
          jinja2
          ruamel-yaml
          msgpack
          urllib3

          influxdb-client
          psycopg
          paho-mqtt

          humanize
          rich

          pygobject3

          pyserial
          pylibftdi
          pylxd
          selenium
        ]))
      geckodriver
      chromedriver

      gobject-introspection
      gtk3
      gtk4
    ];
    inputsFrom = with pkgs; [default];
    meta.platforms = nixpkgs.lib.platforms.linux;
  }
