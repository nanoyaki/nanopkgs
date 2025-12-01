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
  version = "0.1.2-unstable-2025-10-07";

  src = fetchgit {
    url = "https://github.com/ptazithos/wkeys.git";
    rev = "4d7d373578d987719d9f5089d40697e8906c3753";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-312xCT9f3WyoB1C7+olQd/2G0UI0ryQ7SJ0jyvJi2ak=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-0itjjzZfcRQY19mVj4YGVC7hX9EVxK3hyNi3QL3j1Yo=";
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
