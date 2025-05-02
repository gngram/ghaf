# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  buildPythonApplication,
  fetchFromGitHub,
  qemuqmp,
  pyudev,
  psutil,
  inotify-simple,
  lib,
}:
buildPythonApplication {
  pname = "vhotplug";
  version = "0.1";

  propagatedBuildInputs = [
    pyudev
    psutil
    inotify-simple
    qemuqmp
  ];

  doCheck = false;

  src = fetchFromGitHub {
    owner = "gngram";
    repo = "vhotplug";
    rev = "b27b9ffe166a258a1485b8ad15a11c4f8a177642";
    sha256 = "";
  };

  meta = {
    description = "Virtio Hotplug";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
