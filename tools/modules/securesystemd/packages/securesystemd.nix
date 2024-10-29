#{ pkgs,buildPythonPackage, fetchFromGitHub, python3Packages, ... }:
{ pkgs, ... }:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "secure-systemd";
  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "gangaram-tii";
    repo = pname;
    # No release was tagged and PyPI doesn't contain tests.
    rev = "caf2de2f411f5eeaf67ee7e52cb531fb71a937aa";
    hash = "sha256-u8exzAJgcazW7pVmsYiA5owUBe4KW6AJ4ISTHPNlA4I=";
  };

  propagatedBuildInputs = [
    pkgs.python3Packages.sh
  ];

  meta = with pkgs.lib; {
    description = "A Python package to generate secure configuration for systemd service.";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
