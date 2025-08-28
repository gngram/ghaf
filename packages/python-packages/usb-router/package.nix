
# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  buildPythonApplication,
  wheel,
  setuptools,
  qt5,
  pyqt5,
  libsForQt5,
}:
buildPythonApplication {
  pname = "usbrouter";
  version = "0.1.0";
  src = ./usb-router;
  pyproject = true;                     # use pyproject/PEP 517 build

  nativeBuildInputs = [
    setuptools
    wheel
    libsForQt5.wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    pyqt5                       # runtime deps: declare here, not in TOML
    qt5.qtbase qt5.qtwayland
  ];

  buildInputs = [ qt5.qtbase qt5.qtwayland ]; # non-Python libs for runtime
}
