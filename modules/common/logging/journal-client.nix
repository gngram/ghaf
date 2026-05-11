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
  cfg = config.ghaf.logging.journalUploader;
  inherit (config.ghaf.logging) listener;
in
{
  _file = ./journal-client.nix;

  options.ghaf.logging.journalUploader = {
    enable = mkEnableOption "Journal uploader client service";
    endpoint = mkOption {
      description = ''
        Assign endpoint url value to the alloy.service running in
        different log producers. This endpoint URL will include
        protocol, upstream, address along with port value.
      '';
      type = types.str;
      default = "https://${listener.address}:${toString listener.port}";
    };

    tls = {
      caFile = mkOption {
        type = types.nullOr types.path;
        default = "/etc/givc/ca-cert.pem";
        description = "CA bundle used to verify the admin-vm TLS terminator certificate.";
      };
      certFile = mkOption {
        type = types.nullOr types.path;
        default = "/etc/givc/cert.pem";
        description = "Client certificate (PEM) used for mTLS to the admin-vm.";
      };
      keyFile = mkOption {
        type = types.nullOr types.path;
        default = "/etc/givc/key.pem";
        description = "Client private key (PEM) used for mTLS to the admin-vm.";
      };
      minVersion = mkOption {
        type = types.nullOr (
          types.enum [
            "TLS12"
            "TLS13"
          ]
        );
        default = "TLS12";
        description = "Minimum TLS version for the outbound connection.";
      };
    };
  };

  config = mkIf cfg.enable {

    # Local journal retention
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

    environment.etc."systemd/journal-upload.conf".text = ''
      [Upload]
      URL=${cfg.endpoint}
      ServerKeyFile=${cfg.tls.keyFile}
      ServerCertificateFile=${cfg.tls.certFile}
      TrustedCertificateFile=${cfg.tls.caFile}
    '';

    systemd.services.systemd-journal-upload = {
      description = "Journal Remote Upload Service";
      documentation = [ "man:systemd-journal-upload(8)" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-journal-upload --save-state";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        ProtectProc = "invisible";
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestartSteps = 10;
        RestartMaxDelaySec = "60s";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "systemd/journal-upload";
        SupplementaryGroups = [ "systemd-journal" ];
        SystemCallArchitectures = "native";
        DynamicUser = false;
        User = "root";
        Group = "root";
        WatchdogSec = "3min";
        LimitNOFILE = 524288;
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Disable the NixOS module's automatic journal-upload setup to avoid conflicts
    # with the manual service definition.
    services.journald.upload.enable = false;
    /*
        users.users.systemd-journal-upload = {
          isSystemUser = true;
          group = "systemd-journal-upload";
        };
        users.groups.systemd-journal-upload = {};
    */
  };
}
