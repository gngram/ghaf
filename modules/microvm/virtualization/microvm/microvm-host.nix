# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghaf.virtualization.microvm-host;
in {
  options.ghaf.virtualization.microvm-host = {
    enable = lib.mkEnableOption "MicroVM Host";
    networkSupport = lib.mkEnableOption "Network support services to run host applications.";
  };

  config = lib.mkIf cfg.enable {
    microvm.host.enable = true;
    ghaf = {
      systemd = {
        withName = "host-systemd";
        enable = true;
        boot.enable = true;
        withPolkit = true;
        withTpm2Tss = pkgs.stdenv.hostPlatform.isx86;
        withRepart = true;
        withFido2 = true;
        withCryptsetup = true;
        withTimesyncd = cfg.networkSupport;
        withNss = cfg.networkSupport;
        withResolved = cfg.networkSupport;
        withSerial = config.ghaf.profiles.debug.enable;
        withDebug = config.ghaf.profiles.debug.enable;
        withHardenedConfigs = true;
      };
      security = {
        users.strong-password.enable = true;
        users.root.enable = false;
        users.sudo.enable = true;
        system-security.enable = true;
        system-security.lock-kernel-modules = lib.mkDefault config.ghaf.profiles.release.enable;
        network.ipsecurity.enable = true;
        network.bpf-access-level = lib.mkForce 1; # Provide BPF access to privileged users
        fail2ban.enable = true;
      };
    };
  };
}
