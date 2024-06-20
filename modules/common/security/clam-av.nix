# Copyright 2024-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types optionalString concatStringsSep;
  cfg = config.ghaf.security.clamav;
in {
  options.ghaf.security.clamav = {
    enable = mkEnableOption "ClamAV clamd daemon";
    settings = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          bool
          int
          str
          (listOf str)
        ]);
      default = {
        LocalSocket = "/run/clamd.sock";
        FixStaleSocket = true;
        LogFile = "/var/log/clamd.log";
        LogTime = true;
        ExtendedDetectionInfo = true;
        DatabaseDirectory = "/var/lib/clamav";
      };
      description = ''
        ClamAV configuration. Refer to <https://linux.die.net/man/5/clamd.conf>,
        for details on supported values.
      '';
    };

    updaters.freshclam = {
      enable = mkEnableOption "ClamAV freshclam updater";
      frequency = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = ''
            Number of database checks per day.
          '';
        };

        interval = lib.mkOption {
          type = lib.types.str;
          default = "hourly";
          description = ''
            How often freshclam is invoked. See {manpage}`systemd.time(7)` for more
            information about the format.
          '';
        };

        settings = lib.mkOption {
          type =
            with lib.types;
            attrsOf (oneOf [
              bool
              int
              str
              (listOf str)
            ]);
          default = {
            DatabaseDirectory = "/var/lib/clamav";
            LogTime = true;
            LogVerbose = false;
            Debug = false;
            UpdateLogFile = "/var/log/freshclam.log";
          };
          description = ''
            freshclam configuration. Refer to <https://linux.die.net/man/5/freshclam.conf>,
            for details on supported values.
          '';
        };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      services.clamav.daemon.enable = true;
      services.clamav.daemon.settings = cfg.settings;
    })
    (mkIf cfg.updaters.freshclam.enable {
      services.clamav.freshclam.enable = true;
      services.clamav.freshclam.frequency = cfg.updaters.freshclam.frequency;
      services.clamav.freshclam.interval = cfg.updaters.freshclam.interval;
      services.clamav.freshclam.settings = cfg.updaters.freshclam.settings;
    })
  ]);
}
