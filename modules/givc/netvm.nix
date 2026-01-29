# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  ...
}:
let
  cfg = config.ghaf.givc.netvm;
  policycfg = config.ghaf.givc.policyClient;
  inherit (lib)
    mapAttrs
    mkEnableOption
    mkIf
    optionals
    ;
  guivmName = "gui-vm";
  inherit (config.ghaf.networking) hosts;
  inherit (config.networking) hostName;
in
{
  options.ghaf.givc.netvm = {
    enable = mkEnableOption "Enable netvm givc module.";
  };

  config = mkIf (cfg.enable && config.ghaf.givc.enable) {
    assertions = [
      {
        assertion = !config.ghaf.givc.policyAdmin.enable;
        message = "Policy admin cannot be enabled in netvm.";
      }
    ];

    # Configure netvm service
    givc.sysvm = {
      enable = true;
      inherit (config.ghaf.givc) debug;
      transport = {
        name = config.networking.hostName;
        addr = hosts.${hostName}.ipv4;
        port = "9000";
      };
      services = [
        "poweroff.target"
        "reboot.target"
      ]
      ++ optionals config.ghaf.services.power-manager.vm.enable [
        "suspend.target"
        "systemd-suspend.service"
      ]
      ++ optionals config.ghaf.services.performance.net.tuned.enable [
        "net-powersave.service"
        "net-balanced.service"
        "net-performance.service"
        "net-powersave-battery.service"
        "net-balanced-battery.service"
        "net-performance-battery.service"
      ];
      hwidService = true;
      tls.enable = config.ghaf.givc.enableTls;
      admin = lib.head config.ghaf.givc.adminConfig.addresses;
      socketProxy = lib.optionals (builtins.elem guivmName config.ghaf.common.vms) [
        {
          transport = {
            name = guivmName;
            addr = hosts.${guivmName}.ipv4;
            port = "9010";
            protocol = "tcp";
          };
          socket = "/tmp/dbusproxy_net.sock";
        }
      ];
      policyClient = mkIf policycfg.enable {
        enable = true;
        inherit (policycfg) storePath;
        policyConfig = mapAttrs (_name: value: value.dest) policycfg.policies;
      };
    };
    givc.dbusproxy = {
      enable = true;
      system = {
        enable = true;
        user = config.ghaf.users.proxyUser.name;
        socket = "/tmp/dbusproxy_net.sock";
        policy = {
          talk = [
            "org.freedesktop.NetworkManager"
          ];
        };
      };
    };
    ghaf.security.audit.extraRules = [
      "-w /etc/givc/ -p wa -k givc-${hostName}"
    ];
  };
}
