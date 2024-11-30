# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ inputs, ... }:
{
  flake.nixosModules = {
    secure-services.imports = [
      inputs.secure-services.nixosModules.SecureServices
      ./harden.nix
      {
        nixpkgs.overlays = [
          inputs.secure-services.overlays.default
        ];
      }
    ];
  };
}
