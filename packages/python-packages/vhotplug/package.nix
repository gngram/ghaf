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
    rev = "209c96e4c34d881815f5be7b7cdd84a239cb6e43";
    sha256 = "sha256-7ukQEiJQ61PtOKd3qIz+BvW0swwrNkSveXvNdeWDiv8=";
  };

  meta = {
    description = "Virtio Hotplug";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
