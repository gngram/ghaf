# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Ghaf systemd config
  cfg = config.ghaf.systemd;
  apply-service-configs = configs-dir: { 
          services = lib.foldl' (services: s:
            let
              svc = builtins.replaceStrings [".nix"] [""] s;
            in
              services // { ${svc}.serviceConfig = (import "${configs-dir}/${svc}.nix");}
            ) {} (builtins.attrNames (builtins.readDir configs-dir));
        }; 
in
  with lib; {
    options.ghaf.systemd = {
      withHardenedConfigs = mkOption {
        description = "Enable common hardened configs.";
        type = types.bool;
        default = false;
      };
    };

    config = mkIf cfg.withHardenedConfigs {
      
      systemd = mkMerge [
        (apply-service-configs ./hardened-configs/common)
        (mkIf(!cfg.withDebug)(apply-service-configs ./hardened-configs/release))
      ]; 
   
    };
  }
