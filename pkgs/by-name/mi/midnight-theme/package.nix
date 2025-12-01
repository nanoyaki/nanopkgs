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
  version = "fc6512be4b82d824dd5a627430c2a2d09aa3a60d";

  src = fetchgit {
    url = "https://github.com/refact0r/midnight-discord.git";
    rev = "fc6512be4b82d824dd5a627430c2a2d09aa3a60d";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-OceoK064SlY+iucr+l3ZrGWY0OcAGbLI621i2CcnmQQ=";
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
