# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ghaf.security.authn;
  authnCredsDir = "/run/creds/authn";
in
{
  options.ghaf.security.authn = {
    serverPort = lib.mkOption {
      type = lib.types.port;
      default = 900;
      description = "The vsock port the server listens on.";
    };
    agentPort = lib.mkOption {
      type = lib.types.port;
      default = 901;
      description = "The vsock port the agent binds/dials from.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      description = "The authn package to use.";
      default = pkgs.vm-authn-scope;
    };
  };

  options.ghaf.security.authn.server = {
    enable = lib.mkEnableOption "VM Authentication Server";
    settings = lib.mkOption {
      inherit ((pkgs.formats.json { })) type;
      default = { };
      description = ''
        Configuration for the server, mapped directly to `host.json`.
        Detailed documentation is available at
        [docs/server_configuration.md](../../docs/server_configuration.md)
      '';
    };
  };

  config = lib.mkIf cfg.server.enable {
    #environment.systemPackages = [cfg.package];

    # Expose vsock to systemd
    services.udev.extraRules = ''
      KERNEL=="vsock", TAG+="systemd"
    '';

    environment.etc."authn/server.json".source = (pkgs.formats.json { }).generate "host.json" (
      cfg.server.settings
      // {
        server_port = cfg.serverPort;
      }
    );

    boot.kernelModules = [
      "vhost_vsock"
      "vsock_loopback"
    ];

    systemd.services.authn-server = {
      description = "VM authentication host server";

      after = [
        "systemd-modules-load.service"
      ];
      before = [
        "sysinit.target"
      ];

      wants = [
        "dev-vsock.device"
      ];

      wantedBy = [
        "sysinit.target"
      ];

      unitConfig = {
        DefaultDependencies = false;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/authn-scope-server --config /etc/authn/server.json --genkey";
        Restart = "always";
      };
    };

    ghaf.security.authn.server.settings = {
      ca_cert_path = authnCredsDir + "/server/ca_cert.crt";
      ca_key_path = authnCredsDir + "/server/ca_key.pem";
      peer_port = cfg.agentPort;
      cert_validity_days = 30;
      vms = builtins.mapAttrs (_hostname: vm: {
        vm_cid = vm.cid;
        identities = {
          "givc-${vm.name}".ip = vm.ipv4;
        };
      }) config.ghaf.networking.hosts;
    };
  };
}
