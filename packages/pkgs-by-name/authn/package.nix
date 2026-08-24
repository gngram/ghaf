# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "vm-authn-scope";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "gngram";
    repo = "vm-authn-scope";
    rev = "5cb2ae19b4bdb18a04d61d8439adfbb26e2f60f2";
    hash = "sha256-/MRF6TDBl9CCTj+HmA3WIwC9xmjaCDxP/A3s+dFmlz0=";
  };

  cargoHash = "sha256-dUtQvq1hnIWw7FzTe7NSkwfId9zWELN7uSgrpVdsWRQ=";

  doCheck = false;

  meta = {
    description = "VM Authentication Scope Agent and Server";
    homepage = "https://github.com/gngram/vm-authn-scope";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
