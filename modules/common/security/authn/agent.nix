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
  cert_path = authnCredsDir + "/givc-${config.networking.hostName}/cert.crt";
  key_path = authnCredsDir + "/givc-${config.networking.hostName}/key.pem";
  ca_path = authnCredsDir + "/givc-${config.networking.hostName}/ca.crt";
in
{
  options.ghaf.security.authn.agent = {
    enable = lib.mkEnableOption "VM Authentication Agent";

    settings = lib.mkOption {
      inherit ((pkgs.formats.json { })) type;
      default = { };
      description = ''
        Configuration for the agent, mapped directly to `agent.json`.
        Detailed documentation is available at
        [docs/agent_configuration.md](../../docs/agent_configuration.md)
      '';
    };
  };

  config = lib.mkIf cfg.agent.enable {
    #environment.systemPackages = [cfg.package];

    systemd.tmpfiles.rules =
      lib.optional (
        config.givc.admin.enable || config.givc.sysvm.enable || config.givc.host.enable
      ) "d ${authnCredsDir} 0755 root root - -"
      ++ lib.optional config.givc.appvm.enable "d ${authnCredsDir} 0755 appuser appuser - -";

    # Expose vsock to systemd
    services.udev.extraRules = ''
      KERNEL=="vsock", TAG+="systemd"
    '';

    environment.etc."authn/agent.json".source = (pkgs.formats.json { }).generate "agent.json" (
      {
        vm_name = config.networking.hostName;
      }
      // cfg.agent.settings
      // {
        client_port = cfg.agentPort;
      }
    );

    systemd.services.authn-agent = {
      description = "VM authentication agent";
      # start in early boot
      wantedBy = [ "sysinit.target" ];
      unitConfig = {
        DefaultDependencies = false;
      };
      bindsTo = [ "dev-vsock.device" ];
      after = [ "dev-vsock.device" ];
      before = [ "sysinit.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/authn-scope-agent --config /etc/authn/agent.json";
        Restart = "always";
      };
    };
    ghaf.security.authn.agent.settings =
      let
        cert_mode = "0644";
        key_mode = "0600";
      in
      {
        vm_name = config.networking.hostName;
        server_port = config.ghaf.security.authn.serverPort;
        identities =
          (lib.optional
            (
              config.ghaf.givc.enable
              && (config.givc.admin.enable || config.givc.sysvm.enable || config.givc.host.enable)
            )
            {
              name = "givc-${config.networking.hostName}";
              inherit cert_path;
              inherit key_path;
              inherit ca_path;
              inherit cert_mode;
              inherit key_mode;
              owner_user = config.users.users.root.name;
              owner_group = config.users.users.root.group;
            }
          )
          ++ (lib.optional (config.ghaf.givc.enable && config.givc.appvm.enable) {
            name = "givc-${config.networking.hostName}";
            inherit cert_path;
            inherit key_path;
            inherit ca_path;
            inherit cert_mode;
            inherit key_mode;
            owner_user = config.users.users.appuser.name;
            owner_group = config.users.users.appuser.group;
          });

      };

    givc.host.network.tls = lib.mkIf config.givc.host.enable {
      caCertPath = ca_path;
      certPath = cert_path;
      keyPath = key_path;
    };
    givc.sysvm.network.tls = lib.mkIf config.givc.sysvm.enable {
      caCertPath = ca_path;
      certPath = cert_path;
      keyPath = key_path;
    };
    givc.appvm.network.tls = lib.mkIf config.givc.appvm.enable {
      caCertPath = lib.mkForce ca_path;
      certPath = lib.mkForce cert_path;
      keyPath = lib.mkForce key_path;
    };
  };
}
