# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = [
    pkgs.python3
    pkgs.gtk4
  pkgs.gobject-introspection
  pkgs.wrapGAppsHook
  pkgs.gsettings-desktop-schemas
    pkgs.python3Packages.pip
    pkgs.python3Packages.pygobject3
    pkgs.python3Packages.virtualenv
    pkgs.python3Packages.setuptools
    pkgs.python3Packages.wheel
    pkgs.python3Packages.build
    (pkgs.python3Packages.callPackage ./package.nix { })
  ];

  shellHook = ''
    # Create a venv that can see Nix-installed packages (PyQt6)
    if [ ! -d .venv ]; then
      virtualenv --system-site-packages .venv
    fi
    source .venv/bin/activate

    echo "Tip: use 'pip install -e . --no-deps' to avoid pulling dependencies from PyPI"

    echo "Welcome to your Python dev env."
    echo "Now you can run:"
    echo "  pip install -e . --no-deps"

  '';
}
