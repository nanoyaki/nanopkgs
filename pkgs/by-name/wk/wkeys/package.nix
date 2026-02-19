# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  rustPlatform,
  fetchgit,
  pkg-config,
  oldlibcosmicAppHook,
  gtk4-layer-shell,
  gtkmm4,
  libxkbcommon,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wkeys";
  version = "0.1.2-unstable-2026-02-16";

  src = fetchgit {
    url = "https://github.com/ptazithos/wkeys.git";
    rev = "13ceae730f2433f3ac398224dafa539ae55d3f54";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-FFbSfKwNci0Z+CH8tXmLza5dvm14sviFIpZxMQuKzwo=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-deAiMKHkPKDWM57IL1xOvcqEzm0cLC6SktbKCDXZPZE=";
  };

  nativeBuildInputs = [
    pkg-config
    oldlibcosmicAppHook
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
    ];
  };

  meta = {
    homepage = "https://github.com/ptazithos/wkeys";
    description = "On-screen keyboard for the COSMIC Desktop Environment";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "wkeys";
  };
})
