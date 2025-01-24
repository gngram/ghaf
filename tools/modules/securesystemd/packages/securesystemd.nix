#{ pkgs,buildPythonPackage, fetchFromGitHub, python3Packages, ... }:
{ pkgs, ... }:
let
  repository = "secure-services";
  package = pkgs.fetchFromGitHub {
    owner = "gngram";
    repo = repository;
    # No release was tagged and PyPI doesn't contain tests.
    rev = "602cd07c4d28d3671bb1a31a7c1afbe13b34f0a4";
    hash = "sha256-XDy+X0dFATsklAQ/3t+1342DU3WsUxzmDXc3TU++gAI=";
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
