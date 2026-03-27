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
  version = "0-unstable-2026-03-26";

  src = fetchgit {
    url = "https://github.com/refact0r/midnight-discord.git";
    rev = "fa06c760bd1b8a7c4f4f086f3aa810ae45f3e4bf";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-x2Cb0BNHPQ4qf35LLhjMejkvkXx0Cz2qCgQu25txU/k=";
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
