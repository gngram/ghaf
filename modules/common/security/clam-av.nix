# Copyright 2024-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    mkForce
    mkDefault
    mkOption
    types
    optionals
    optionalString
    concatStringsSep;
  cfg = config.ghaf.security.clamav;
  clamdlog = "/var/log/clamav/clamd.log";
  freshclamlog = "/var/log/clamav/freshclam.log";
  clamdconf = "/etc/clamav/clamd.conf";
  quarantinedir = "/var/lib/clamav/quarantine";
  clamuser = "clamav";
  clamgroup = "clamav";
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
	      FixStaleSocket = true;
        LogTime = mkDefault true;
        ExtendedDetectionInfo = mkDefault true;
        LogFile = mkForce clamdlog;
        OnAccessExcludeUID = 0;
        OnAccessExcludeUname = clamuser;
      };
      description = ''
        ClamAV configuration. Refer to <https://linux.die.net/man/5/clamd.conf>,
        for details on supported values.
      '';
    };

    scanDirectories = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = ''
        List of directories to scan.
        The default includes /home by default.
      '';
    };
    scanInterval = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = ''
        How often clamdscan is invoked. See {manpage}`systemd.time(7)` for more
        information about the format.
        By default this runs using 10 cores at most, be sure to run it at a time of low traffic.
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
            LogTime = true;
            LogVerbose = false;
            Debug = false;
            UpdateLogFile = mkForce freshclamlog;
          };
          description = ''
            freshclam configuration. Refer to <https://linux.die.net/man/5/freshclam.conf>,
            for details on supported values.
          '';
        };
    };
    onAccessScanning = {
      enable = mkEnableOption "On-access scanning using clamonacc (fanotify)";
      removeInfected = mkEnableOption "Remove infected files";
      quarantine = mkEnableOption "Quarantine infected files";
      includePaths = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "/home" ];
        description = "Directories to watch/scan on access.";
      };
      excludePaths = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "/home/user/.cache" "/nix/store" ];
        description = "Directories to exclude from on-access scanning.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
        assertions = [
            {
              assertion =
                !(cfg.onAccessScanning.enable) ||
                (!(cfg.onAccessScanning.quarantine && cfg.onAccessScanning.removeInfected));
              message = "When onAccessScanning.enable = true, only one of quarantine or remove may be true.";
            }

            {
              assertion =
                !(cfg.onAccessScanning.enable) ||
                (builtins.length cfg.onAccessScanning.includePaths > 0);
              message = "When onAccessScanning.enable = true, includePaths must contain at least one path.";
            }
          ];
    })
    ({
      services.clamav.daemon.enable = true;
      services.clamav.daemon.settings = cfg.settings;
      systemd.services.clamav-daemon.serviceConfig = {
        DynamicUser = false;
        User = clamuser;
        Group = clamgroup;
      };
      systemd.services.clamav-freshclam.serviceConfig = {
        DynamicUser = false;
        User = clamuser;
        Group = clamgroup;
      };
      systemd.tmpfiles.rules = [
        "d /var/log/clamav 0750 ${clamuser} ${clamgroup} -"
        "f /var/log/clamav/clamd.log 0640 ${clamuser} ${clamgroup} -"
        "f /var/log/clamav/freshclam.log 0640 ${clamuser} ${clamgroup} -"
        "d /var/lib/clamav 0755 ${clamuser} ${clamgroup} -"
        "d /var/lib/clamav/quarantine 0755 ${clamuser} ${clamgroup} -"
        "d /run/clamav 0755 ${clamuser} ${clamgroup} -"
      ];
    })
    (mkIf cfg.updaters.freshclam.enable {
      services.clamav.updater.enable = true;
      services.clamav.updater.frequency = cfg.updaters.freshclam.frequency;
      services.clamav.updater.interval = cfg.updaters.freshclam.interval;
      services.clamav.updater.settings = cfg.updaters.freshclam.settings ;
    })
    (mkIf ((builtins.length cfg.scanDirectories) > 0) {
      services.clamav.scanner.enable = true;
      services.clamav.scanner.scanDirectories = cfg.scanDirectories;
      services.clamav.scanner.interval = cfg.scanInterval;
    })

    (mkIf cfg.onAccessScanning.enable {
      systemd.services.clamonacc = {
        enable = true;
        description = "ClamAV On-Access Scanner (fanotify)";
        after = [ "clamav-daemon.service" "systemd-homed-activate.service"];
        #requires = [ "clamav-daemon.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = concatStringsSep " " ([
            "${pkgs.clamav}/bin/clamonacc"
            "-v"
            "--foreground"
            "--log=/var/log/clamav/clamonacc.log"
            "--fdpass"
            "--config-file=${clamdconf}"
            "--watch-list=/etc/clamav/watch.list"
            "--exclude-list=/etc/clamav/exclude.list"

          ] ++
          optionals cfg.onAccessScanning.removeInfected [
            "--remove"
          ] ++
          optionals cfg.onAccessScanning.quarantine [
            "--move=${quarantinedir}"
          ]);
          Restart = "on-failure";
          RestartSec = "2s";
        };
      };
      environment.etc = {
        "clamav/watch.list" = {
          text = lib.concatStringsSep "\n" (cfg.onAccessScanning.includePaths ++ [""]);
        };
        "clamav/exclude.list" = {
          text = lib.concatStringsSep "\n" (cfg.onAccessScanning.excludePaths ++ [""]);
        };
      };
    })

  ]);
}
