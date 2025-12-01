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
  version = "0.0.10-unstable-2025-11-24";

  src = fetchgit {
    url = "https://github.com/championpeak87/cosmic-classic-menu.git";
    rev = "6fa2ca7c54fe3cee3e4263704975da58ded569a4";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-KtSSzLvPCiYnrM84lVUILsjo8E0TzLuXBuw2fs4btp0=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-OSzPsqyL7rB5X2On6kKRecDnQgbRC+3QZo9yGjkyYa0=";
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
