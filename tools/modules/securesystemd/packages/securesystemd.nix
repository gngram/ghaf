#{ pkgs,buildPythonPackage, fetchFromGitHub, python3Packages, ... }:
{ pkgs, ... }:
let
  repository = "secure-services";
  package = pkgs.fetchFromGitHub {
    owner = "gngram";
    repo = repository;
    # No release was tagged and PyPI doesn't contain tests.
    rev = "27982511e23b5cc9438fd7a95741aafcc3a083b9";
    hash = "sha256-b/c9JHvGW3aZTl3D6aqZGkpLyB4RxN8ai08+VAgiLjI=";
  };
in
pkgs.python3Packages.buildPythonPackage rec {
  pname = repository;
  version = "0.0.1";
  src = package + "/packages/service-seal";

  propagatedBuildInputs = [
    pkgs.python3Packages.sh
  ];

  meta = with pkgs.lib; {
    description = "A Python package to generate secure configuration for systemd service.";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
