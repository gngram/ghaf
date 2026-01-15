# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ config, lib, ... }:
let
  cfg = config.ghaf.givc.adminvm;
  inherit (lib) mkEnableOption mkIf;
  inherit (config.ghaf.givc.adminConfig) name;
  systemHosts = lib.lists.subtractLists (config.ghaf.common.appHosts ++ [ name ]) (
    builtins.attrNames config.ghaf.networking.hosts
  );
in
{
  options.ghaf.givc.adminvm = {
    enable = mkEnableOption "Enable adminvm givc module.";
  };

  config = mkIf (cfg.enable && config.ghaf.givc.enable) {
    # Configure admin service
    givc.admin = {
      enable = true;
      inherit (config.ghaf.givc) debug;
      inherit name;
      inherit (config.ghaf.givc.adminConfig) addresses;
      services = map (host: "givc-${host}.service") systemHosts;
      tls.enable = config.ghaf.givc.enableTls;
      policyAdmin = {
        enable = true;
        defaultPolicies = {
          # TODO: Host on tiiuae
          url = "https://github.com/gngram/policy-store.git";
          rev = "18b896782587b220d144c166e9acf83ff5beb194";
          sha256 = "sha256-V77S1fJk2mjNav2tSmhd+M/PQyMJcd8kEhrX0W8Bqew=";
          policies = {
            "proxy-config" = {
              vms = [ "business-vm" ];
            };
          };
        };

        liveUpdate = {
          remote = {
            URLs = {
              enable = true;
              policies = {
                "proxy-config" = {
                  vms = [ "business-vm" ];
                  url = "https://raw.githubusercontent.com/tiiuae/ghaf-rt-config/main/network/proxy/ghaf.pac";
                  poll_interval_secs = 30;
                };
                "firewall-rules" = {
                  vms = [ "chrome-vm" ];
                  url = "https://raw.githubusercontent.com/gngram/policy-store/test-policy/vm-policies/firewall-rules/fw.nft";
                  poll_interval_secs = 30;
                };
              };
            };

            gitRepo = {
              enable = false;
              ref = "test-policy";
              poll_interval_secs = 30;
              extraPolicies = {
                "firewall-rules" = {
                  vms = [ "chrome-vm" ];
                };
              };
            };
          };
        };
      };
    };
    ghaf.security.audit.extraRules = [
      "-w /etc/givc/ -p wa -k givc-${name}"
    ];
  };
}
