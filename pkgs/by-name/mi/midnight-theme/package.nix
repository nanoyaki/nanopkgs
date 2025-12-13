# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchgit,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "midnight-theme";
  version = "680e1a5754160a7eee4f2fec46b27ebd3373a965";

  src = fetchgit {
    url = "https://github.com/refact0r/midnight-discord.git";
    rev = "680e1a5754160a7eee4f2fec46b27ebd3373a965";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-napai8il4jBtG+MaMBiF3hPPIJa78qafL0demzBgdMQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r themes $out/share

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--src-only"
      "--version=branch"
    ];
  };

  meta = {
    description = "Dark, customizable discord theme";
    homepage = "https://github.com/refact0r/midnight-discord";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
