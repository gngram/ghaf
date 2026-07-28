# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  ...
}:

{
  _file = ./workloads.nix;

  config = {
    ghaf.security.spire.agents.downstream.workloads =
      lib.mkIf config.ghaf.security.spire.agents.downstream.enable
        (
          lib.concatLists [
            # Base workloads
            [
              {
                name = "user.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/user@.service"
                ];
              }
            ]

            (lib.optionals config.givc.sysvm.enable [
              {
                name = "givc-${config.givc.sysvm.network.agent.transport.name}";
                selectors = [
                  "systemd:id:givc-${config.givc.sysvm.network.agent.transport.name}.service"
                ];
              }
            ])

            (lib.optionals config.givc.host.enable [
              {
                name = "givc-host-${config.givc.host.network.agent.transport.name}";
                selectors = [
                  "systemd:id:givc-${config.givc.host.network.agent.transport.name}.service"
                ];
              }
            ])

            (lib.optionals config.givc.appvm.enable [
              {
                name = "givc-${config.givc.appvm.network.agent.transport.name}";
                selectors = [
                  "systemd:id:givc-${config.givc.appvm.network.agent.transport.name}.service"
                ];
              }
            ])

            (lib.optionals config.givc.admin.enable [
              {
                name = "givc-admin.service";
                selectors = [
                  "systemd:id:givc-admin.service"
                ];
              }
            ])

            (lib.optionals (config.ghaf.microvm-boot.enable or false) [
              {
                name = "wait-for-ui.service";
                selectors = [
                  "systemd:id:wait-for-ui.service"
                ];
              }
              {
                name = "wait-for-login.service";
                selectors = [
                  "systemd:id:wait-for-login.service"
                ];
              }
            ])

            (lib.optionals (config.systemd.services.ghaf-wipe-request.enable or false) [
              {
                name = "ghaf-wipe-request.service";
                selectors = [
                  "systemd:id:ghaf-wipe-request.service"
                ];
              }
            ])

            (lib.optionals config.ghaf.services.power-manager.suspend.enable [
              {
                name = "pre-sleep-poweroff.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/pre-sleep-poweroff@.service"
                ];
              }
              {
                name = "pre-sleep-fake-suspend.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/pre-sleep-fake-suspend@.service"
                ];
              }
              {
                name = "pre-sleep-pci-suspend.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/pre-sleep-pci-suspend@.service"
                ];
              }
              {
                name = "pre-sleep-gpu-suspend.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/pre-sleep-gpu-suspend@.service"
                ];
              }
              {
                name = "post-resume-poweroff.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/post-resume-poweroff@.service"
                ];
              }
              {
                name = "post-resume-fake-suspend.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/post-resume-fake-suspend@.service"
                ];
              }
              {
                name = "post-resume-pci-suspend.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/post-resume-pci-suspend@.service"
                ];
              }
              {
                name = "post-resume-gpu-suspend.service";
                selectors = [
                  "systemd:fragment_path:/etc/systemd/system/post-resume-gpu-suspend@.service"
                ];
              }
            ])

            (lib.optionals (config.systemd.services.ghaf-timezone-forwarder.enable or false) [
              {
                name = "ghaf-timezone-forwarder.service";
                selectors = [
                  "systemd:id:ghaf-timezone-forwarder.service"
                ];
              }
            ])

            (lib.optionals (config.systemd.services.tuned.enable or false) [
              {
                name = "tuned.service";
                selectors = [
                  "systemd:id:tuned.service"
                ];
              }
            ])

            (lib.optionals (config.systemd.services.ctapproxy.enable or false) [
              {
                name = "ctapproxy.service";
                selectors = [
                  "systemd:id:ctapproxy.service"
                ];
              }
            ])
          ]
        );
  };
}
