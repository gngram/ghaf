# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # Python + PyGObject
    python313
    python313Packages.pygobject3

    # GTK & GI runtime
    gtk4
    gobject-introspection

    # Display backends (Wayland/X11) — harmless if both are present
    wayland
  ];

  shellHook = ''
    # Prefer Wayland if available, fallback to X11
    #export GDK_BACKEND=wayland

    # Ensure typelibs are discoverable in plain shells (usually OK without this,
    # but helpful in some setups)
    #export GI_TYPELIB_PATH="${pkgs.gtk3}/lib/girepository-1.0:${pkgs.gobject-introspection}/lib/girepository-1.0:$GI_TYPELIB_PATH"
    #export XDG_DATA_DIRS="${pkgs.gtk3}/share:$XDG_DATA_DIRS"
  '';
}

