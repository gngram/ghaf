# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Common ghaf modules
#

{
  lib,
  config,
  pkgs,
  vmName,
  ...
}:
{
  imports = [
    ./common.nix
    ./host.nix
    ./servers.nix
    ./clients.nix
  ];
}
