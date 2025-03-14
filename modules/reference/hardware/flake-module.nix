# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Reference hardware modules
#
_: {
  flake.nixosModules = {
    hardware-alienware-m18-r2.imports = [
      {
        ghaf.hardware.definition = import ./alienware/alienware-m18.nix;
        ghaf.virtualization.microvm.guivm.extraModules = [
          (import ./alienware/extra-config.nix)
        ];
      }
    ];
    hardware-dell-latitude-7230.imports = [
      {
        ghaf.hardware.definition = import ./dell-latitude/definitions/dell-latitude-7230.nix;
      }
    ];
    hardware-dell-latitude-7330.imports = [
      {
        ghaf.hardware.definition = import ./dell-latitude/definitions/dell-latitude-7330.nix;
      }
    ];
    hardware-lenovo-x1-carbon-gen10.imports = [
      {
        ghaf.hardware.definition = import ./lenovo-x1/definitions/x1-gen10.nix;
      }
    ];
    hardware-lenovo-x1-carbon-gen11.imports = [
      {
        ghaf.hardware.definition = import ./lenovo-x1/definitions/x1-gen11.nix;
      }
    ];
    hardware-lenovo-x1-carbon-gen12.imports = [
      {
        ghaf.hardware.definition = import ./lenovo-x1/definitions/x1-gen12.nix;
      }
    ];
    imx8.imports = [ ./imx8 ];
    jetpack.imports = [ ./jetpack ];
    jetpack-microvm.imports = [ ./jetpack-microvm ];
    polarfire.imports = [ ./polarfire ];
  };
}
