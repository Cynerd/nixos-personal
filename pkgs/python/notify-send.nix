{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "notify-send";
  version = "0.0.20";

  src = fetchPypi {
    inherit pname version;
    sha256 = "6fddbc5b201728984d2de809959bb6aecf9abb0de5cfa55c7324ca6f48f41e03";
  };

  meta = with lib; {
    description = "Notify send";
    homepage = "https://pypi.org/project/notify-send";
    license = licenses.gpl3;
  };
}
