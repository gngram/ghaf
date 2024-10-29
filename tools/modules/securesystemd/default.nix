# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.ghaf.tools = {
    enable = lib.mkOption {
      description = "Enable tooling to analyze and debug Ghaf.";
      type = lib.types.bool;
      default = true;
    };

  };

  config = lib.mkIf config.ghaf.tools.enable {
    environment.systemPackages = with pkgs; [
      (callPackage ./packages/securesystemd.nix { })
    ];
  };
}
