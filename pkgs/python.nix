_: prev: {
  # NixPkgs patches
  sphinx-book-theme = prev.sphinx-book-theme.overrideAttrs {
    pythonRelaxDeps = ["pydata-sphinx-theme"];
  };
}
