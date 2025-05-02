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
    rev = "d901c7da97ded4cc0c2730e87675cdd9dc8651d6";
    sha256 = "sha256-1tYQfNQPZdiLdxFk/TYSbRVSTU4ZjXma0DC/8yALhxM=";
  };

  meta = {
    description = "Virtio Hotplug";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
