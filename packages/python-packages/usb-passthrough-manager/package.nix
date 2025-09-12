# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{ 
  buildPythonPackage,
  qt6,
  pyqt6,
  setuptools,
  wheel,
  ... 
}:
buildPythonPackage {
  pname = "usb_passthrough_core";
  version = "0.1.0";
  src = ./usb_passthrough_manager;
  pyproject = true;


  /*
  build-system = [
    setuptools
    wheel
    qt6.wrapQtAppsHook
  ];
  */

  propagatedBuildInputs = [
    pyqt6
    qt6.qtbase
    qt6.qtwayland
  ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook 
    setuptools
    wheel
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  pythonImportsCheck = [ "upm" ];
}
