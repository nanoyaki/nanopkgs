# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  rustPlatform,
  pkg-config,
  libcosmicAppHook,
  gtk4-layer-shell,
  gtkmm4,
  libxkbcommon,

  _sources,
}:

rustPlatform.buildRustPackage {
  inherit (_sources.wkeys)
    pname
    version
    src
    date
    ;

  cargoLock = _sources.wkeys.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    gtk4-layer-shell
    gtkmm4
    libxkbcommon
  ];

  preInstall = ''
    mkdir -p $out/share/{applications,cosmic/net.pithos.applet.wkeys}

    install -m644 $src/cosmic-applet/assets/wkeys-applet.desktop \
      $out/share/applications/net.pithos.applet.wkeys.desktop
  '';

  meta = {
    homepage = "https://github.com/ptazithos/wkeys";
    description = "On-screen keyboard for the COSMIC Desktop Environment";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "wkeys";
  };
}
