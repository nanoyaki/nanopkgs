# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  rustPlatform,
  stdenv,
  just,
  pkg-config,
  nixosTests,
  libxkbcommon,
  libcosmicAppHook,

  _sources,
}:

rustPlatform.buildRustPackage {
  inherit (_sources.cosmic-classic-menu)
    pname
    version
    src
    date
    ;

  cargoLock = _sources.cosmic-classic-menu.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    just
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    libxkbcommon
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-classic-menu"
    "--set"
    "settings-bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-classic-menu-settings"
  ];

  passthru.tests = {
    inherit (nixosTests)
      cosmic
      cosmic-autologin
      cosmic-noxwayland
      cosmic-autologin-noxwayland
      ;
  };

  meta = {
    homepage = "https://github.com/championpeak87/cosmic-classic-menu";
    description = "Classic menu for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-classic-menu";
  };
}
