# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{
  buildPythonPackage,
  setuptools,
  wheel,

  # GTK / GI runtime
  gtk4,
  gobject-introspection,
  wrapGAppsHook,
  gsettings-desktop-schemas,
  #adwaita-icon-theme,

  # Python packages
  pygobject3,
}:
buildPythonPackage {
  pname = "usb_passthrough";
  version = "0.1.0";
  src = ./usb_passthrough_manager;
  pyproject = true;

  nativeBuildInputs = [
    setuptools
    wheel
    gobject-introspection
    wrapGAppsHook
  ];

  propagatedBuildInputs = [
    pygobject3
  ];

  # GTK & runtime assets
  buildInputs = [
    gtk4
    gsettings-desktop-schemas
    #adwaita-icon-theme
  ];

  pythonImportsCheck = [ "upm" ];
}
