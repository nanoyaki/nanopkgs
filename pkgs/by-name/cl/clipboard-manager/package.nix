# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  rustPlatform,
  fetchgit,
  just,
  pkg-config,
  nixosTests,
  libcosmicAppHook,
  libxkbcommon,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clipboard-manager";
  version = "0.1.0-unstable-2026-03-24";

  src = fetchgit {
    url = "https://github.com/cosmic-utils/clipboard-manager.git";
    rev = "d473e8f09e8bc2289a76707898063a13714c79dc";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-RNRSShrT7wS4GmQNd3tXtT8G/4qLM9zxntXgBQ6C7ps=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-+yqFV8HdPjkVny+6FKkZFEQAq1rwe7JXmoTJ7zge8bg=";
  };

  postPatch = ''
    substituteInPlace justfile \
      --replace-fail '`git rev-parse --short HEAD`' "'${finalAttrs.version}'"
  '';

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
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
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
    homepage = "https://github.com/cosmic-utils/clipboard-manager";
    description = "Clipboard manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-clipboard-manager";
  };
})
