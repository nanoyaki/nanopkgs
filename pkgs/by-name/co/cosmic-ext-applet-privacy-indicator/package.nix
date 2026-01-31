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
  version = "0.1.3-unstable-2026-01-21";

  src = fetchFromGitHub {
    owner = "D-Brox";
    repo = "cosmic-ext-applet-privacy-indicator";
    rev = "f94a5e37c0a3f2f183d7fbddff8e5c6a9b226be0";
    hash = "sha256-ZswsyMvcD9b3GblNIB9VSHqlabL0hNcSaK2WGZYuqOs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-ySjA8nQg9mSnGntcGdNGUSn2o2hMS4WDnq9U611ANF8=";
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
