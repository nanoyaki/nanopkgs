# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  just,
  pkg-config,
  nixosTests,
  oldlibcosmicAppHook,
  libxkbcommon,
  pipewire,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-ext-applet-privacy-indicator";
  version = "0.2.0-unstable-2026-02-10";

  src = fetchFromGitHub {
    owner = "D-Brox";
    repo = "cosmic-ext-applet-privacy-indicator";
    rev = "e69833cf8b31813d5468da7eeea6311f1621d702";
    hash = "sha256-LivssKbrzAO4kuoNcE6evs4etaiFgH0UWeOSzHtgd1A=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-Ul17dBobjheF4wUFx/leb0XkyXjqBdOfM41e4yBYHio=";
  };

  nativeBuildInputs = [
    just
    pkg-config
    oldlibcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libxkbcommon
    pipewire
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/${finalAttrs.pname}"
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "-F"
        "--version"
        "branch"
      ];
    };

    tests = {
      inherit (nixosTests)
        cosmic
        cosmic-autologin
        cosmic-noxwayland
        cosmic-autologin-noxwayland
        ;
    };
  };

  meta = {
    homepage = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator";
    description = "Privacy indicators for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-privacy-indicator";
  };
})
