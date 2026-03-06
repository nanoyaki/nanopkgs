# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  rustPlatform,
  fetchgit,
  stdenv,
  just,
  pkg-config,
  nixosTests,
  libxkbcommon,
  oldlibcosmicAppHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-classic-menu";
  version = "0.0.12-unstable-2026-03-05";

  src = fetchgit {
    url = "https://github.com/championpeak87/cosmic-classic-menu.git";
    rev = "163f0ea66085ae99b7335439850b2c8e680409a2";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-EUFIDg2VpNXOEAIM+7Zga4MPx86XhKMlUkIHxxc07Wo=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-t0mDmhHSj1SO7ShUW8b7C/C+F0Y+yV0dzEO+5KNAg2s=";
  };

  nativeBuildInputs = [
    just
    pkg-config
    oldlibcosmicAppHook
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
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-classic-menu-applet"
    "--set"
    "settings-bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-classic-menu-settings"
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "-F"
        "--version"
        "branch=master"
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
    homepage = "https://github.com/championpeak87/cosmic-classic-menu";
    description = "Classic menu for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-classic-menu-applet";
  };
})
