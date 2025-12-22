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
  version = "0.0.10-unstable-2025-12-21";

  src = fetchgit {
    url = "https://github.com/championpeak87/cosmic-classic-menu.git";
    rev = "d9753efe9f3a7dc452bac7d15f54ed1d2790e6f4";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-xiM9O37lZEv8Jfc3cBp31zKRXmUa+Xy9oipjAeFdPjE=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-xflF6v6pDtEHydC5YM+mHBjf+GFgDXgIzo4ntPQac7w=";
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
        ''branch=master''
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
