{
  python3Packages,
  fetchFromGitHub,
}:
let

  pypkg = {
    buildPythonPackage,
    click,
  }:
    buildPythonPackage {
      pname = "lorem_text";
      version = "2.1";
      src = fetchFromGitHub {
        owner = "TheAbhijeet";
        repo = "lorem_text";
        rev = "63a26b95a86f696d23ba059eac70ba1d78e553fb";
        sha256 = "lTksWfXaUxmtWiGK+8kEwHNGNlluX+q3FWXZfzfEDCk=";
      };
      propagatedBuildInputs = [click];
      passthru.pythonPackage = pypkg;
    };

in python3Packages.callPackage pypkg { }
