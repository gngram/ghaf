# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ prev }:
prev.cosmic-greeter.overrideAttrs (_oldAttrs: {
  src = {
    outPath = /home/gangaram/playground/cosmic-greeter;
    rev = "local-dirty";
    shortRev = "dirty";
    tag = "local-dirty";
  };

  patches = [ ];
})
