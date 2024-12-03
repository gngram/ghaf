# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  pkgs,
  config,
  lib,
  ...
}:
let
  pdfscan = final: prev: {
      pdfscan = pkgs.callPackage ../../../packages/pdfscan { };
    };
in
{
  options.ghaf.services.pdfscan = {
    enable = lib.mkOption {
      description = "Enable pdfscanner tool.";
      type = lib.types.bool;
      default = true;
    };
  };

  config = {
    nixpkgs.overlays = [ pdfscan ];
    systemd.services.pdfscan = {
      description = "PDFscan Service";
      after = [ "network.target" ];
      wants = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.pdfscan}/bin/pdfscan";
        Restart = "always";             # Restart on failure
        RestartSec = "5s";              # Wait 5 seconds before restarting
        Type = "simple";                # Continuous listening service
        StandardOutput = "journal+console";
        StandardError = "journal+console";
      };

      wantedBy = [ "multi-user.target" ]; # Enable auto-start at boot
    };
  };
}
