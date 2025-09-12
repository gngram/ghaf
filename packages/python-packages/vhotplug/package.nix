# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  pkgs,
  buildPythonApplication,
  fetchFromGitHub,
  qemu-qmp,
  pyudev,
  psutil,
  inotify-simple,
  setuptools,
  qt6,
}:
buildPythonApplication {
  pname = "vhotplug";
  version = "0.1";
  pyproject = true;

  propagatedBuildInputs = [
    pyudev
    psutil
    inotify-simple
    qemu-qmp
    (pkgs.python3Packages.callPackage ./../usb-passthrough-manager/package.nix {})
  ];

  doCheck = false;
  /*
  src = fetchFromGitHub {
    owner = "gngram";
    repo = "vhotplug";
    rev = "0c9fd704a364d8006929337ff8287663da2cf86f";
    sha256 = "sha256-lendPk0LLOuXNV8YfR0Qnxzraua76Ebdao/lm3r68ME=";
  };
  */
  src = ./vhotplug;

  build-system = [ setuptools ];
  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  meta = {
    description = "Virtio Hotplug";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
