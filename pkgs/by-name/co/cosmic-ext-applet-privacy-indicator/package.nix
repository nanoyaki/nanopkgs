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
  version = "0.1.2-unstable-2025-07-03";

  src = fetchFromGitHub {
    owner = "D-Brox";
    repo = "cosmic-ext-applet-privacy-indicator";
    rev = "2d3b0efec5a95cf704e414f6e3005641f3aa3666";
    hash = "sha256-iTdCn5IbOs+g9MeC+EDUGSYxlHTrmhouvL7Y6Y3rK/M=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-Tbcjnbjyo+FoYtRe5KnPiEzV+1PkzHOnbVDRe/pJul0=";
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
