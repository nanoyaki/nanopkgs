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
  version = "87490c1ee9a5b9cae150074aa160b49b153b7787";

  src = fetchgit {
    url = "https://github.com/refact0r/midnight-discord.git";
    rev = "87490c1ee9a5b9cae150074aa160b49b153b7787";
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
