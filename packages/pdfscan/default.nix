#{ pkgs,buildPythonPackage, fetchFromGitHub, python3Packages, ... }:
{ pkgs, ... }:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "ml-pdfscanner";
  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "gangaram-tii";
    repo = pname;
    # No release was tagged and PyPI doesn't contain tests.
    rev = "80dc799178966a7ea8c29b108467f4b0fe4658ff";
    hash = "sha256-cewW9VcWHmjsuEH7KzxD+OncZuxcC4/pQNNw3m1SjsA=";
  };

  propagatedBuildInputs = [
    pkgs.python3Packages.pandas
    pkgs.python3Packages.xgboost
  ];

  meta = with pkgs.lib; {
    description = "A Python package to scan pdf for security threat";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
