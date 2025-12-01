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
  oldlibcosmicAppHook,
  libxkbcommon,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clipboard-manager";
  version = "0.1.0-unstable-2025-11-27";

  src = fetchgit {
    url = "https://github.com/cosmic-utils/clipboard-manager.git";
    rev = "4e509f5dd9513db58a699748314f388ed4664348";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-a96jEzbKlgScnFzbqs6ckpm8m19l4/mZt074GeOsUHI=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-DmxrlYhxC1gh5ZoPwYqJcAPu70gzivFaZQ7hVMwz3aY=";
  };

  postPatch = ''
    substituteInPlace justfile \
      --replace-fail '`git rev-parse --short HEAD`' "'${finalAttrs.version}'"
  '';

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
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
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
    homepage = "https://github.com/cosmic-utils/clipboard-manager";
    description = "Clipboard manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-clipboard-manager";
  };
})
