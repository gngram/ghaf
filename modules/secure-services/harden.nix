# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ghaf.systemd;
in
{
  options.ghaf.systemd = {
    withHardenedConfigs = lib.mkOption {
      description = "Enable common hardened configs.";
      type = lib.types.bool;
      default = false;
    };

    excludedHardenedConfigs = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      example = [ "sshd.service" ];
      description = ''
        A list of units to skip when applying hardened systemd service configurations.
        The main purpose of this is to provide a mechanism to exclude specific hardened
        configurations for fast debugging and problem resolution.
      '';
    };

    logLevel = lib.mkOption {
      description = ''
        Log Level for systemd services.
                  Available options: "emerg", "alert", "crit", "err", "warning", "info", "debug"
      '';
      type = lib.types.str;
      default = "info";
    };
  };

  config = lib.mkIf cfg.withHardenedConfigs {
    secure-services = {
      enable = true;
      exclude =
        (cfg.excludedHardenedConfigs or [ ])
        ++ lib.optional (!cfg.withDebug) [
          "NetworkManager.service"
          "audit.service"
          "sshd.service"
          "user@.service"
        ];
      log-level = cfg.logLevel;
    };
    environment.systemPackages = [ pkgs.serviceseal ];
  };
}
