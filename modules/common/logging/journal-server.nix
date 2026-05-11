# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    optionalString
    ;
  cfg = config.ghaf.logging.journalServer;
in
{
  _file = ./journal-server.nix;

  options.ghaf.logging.journalServer = {
    enable = mkEnableOption "Logs aggregator server";

    tls = {
      caFile = mkOption {
        type = types.nullOr types.path;
        default = "/etc/givc/ca-cert.pem";
        description = "Optional CA bundle for server verification (e.g., /etc/givc/ca-cert.pem). If null, use system CAs.";
      };
      certFile = mkOption {
        type = types.nullOr types.path;
        default = "/etc/givc/cert.pem";
        description = "Client certificate (PEM) used for mTLS.";
      };
      keyFile = mkOption {
        type = types.nullOr types.path;
        default = "/etc/givc/key.pem";
        description = "Client private key (PEM) used for mTLS.";
      };
    };
  };

  config = mkIf cfg.enable {

    # Local journal retention for admin-vm's own logs
    services.journald = {
      extraConfig = mkIf config.ghaf.logging.journalRetention.enable ''
        MaxRetentionSec=${config.ghaf.logging.journalRetention.maxRetention}
        MaxFileSec=${config.ghaf.logging.journalRetention.MaxFileSec}
        SystemMaxUse=${config.ghaf.logging.journalRetention.maxDiskUsage}
        SystemMaxFileSize=100M
        Storage=persistent
        ${optionalString config.ghaf.logging.fss.enable ''
          Seal=yes
        ''}
      '';
    };

    environment.etc."systemd/journal-remote.conf".text = ''
      [Remote]
      SplitMode=host
      ServerKeyFile=${cfg.tls.keyFile}
      ServerCertificateFile=${cfg.tls.certFile}
      TrustedCertificateFile=${cfg.tls.caFile}
    '';

    systemd.services.systemd-journal-remote = {
      description = "Journal Remote Sink Service";
      documentation = [
        "man:systemd-journal-remote(8)"
        "man:journal-remote.conf(5)"
      ];
      requires = [ "systemd-journal-remote.socket" ];
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-journal-remote --listen-https=-3 --output=/var/log/journal-remote/";
        LockPersonality = true;
        LogsDirectory = "journal-remote";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        ProtectProc = "invisible";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        DynamicUser = false;
        User = "root";
        Group = "root";
        SystemCallArchitectures = "native";
        WatchdogSec = "3min";
        LimitNOFILE = 524288;
      };
      # The 'Also' directive in systemd unit files is typically handled by NixOS
      # by ensuring the dependency is listed in 'requires' or 'wantedBy'.
      # Since systemd-journal-remote.socket is required, it will be activated.
      # No explicit 'Also' mapping is needed here.
    };

    systemd.sockets.systemd-journal-remote = {
      description = "Journal Remote Sink Socket";
      socketConfig = {
        ListenStream = "0.0.0.0:${toString config.ghaf.logging.listener.port}";
      };
      wantedBy = [ "sockets.target" ];
    };

    # Disable the NixOS module's automatic journal-remote setup to avoid conflicts
    # with the manual service/socket definitions.
    services.journald.remote.enable = false;

    /*
        users.users.systemd-journal-remote = {
          isSystemUser = true;
          group = "systemd-journal-remote";
        };
        users.groups.systemd-journal-remote = {};
    */
    networking.firewall.allowedTCPPorts = [ config.ghaf.logging.listener.port ];

  };
}
