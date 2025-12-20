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
  version = "0-unstable-2025-12-19";

  src = fetchgit {
    url = "https://github.com/refact0r/midnight-discord.git";
    rev = "714c4f8f3767c55a81bfe7dc3133918a2448fabc";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-8+L9meaGBV/lxV6QY+fWg4Z87AEvs90N06qHViadgqE=";
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
