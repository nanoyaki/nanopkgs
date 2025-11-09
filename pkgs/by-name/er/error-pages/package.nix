# SPDX-FileCopyrightText: 2025 Hana Kretzer <contact@nanoyaki.space>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  importNpmLock,
  nodejs,

  _sources,
}:

stdenvNoCC.mkDerivation {
  inherit (_sources.error-pages)
    pname
    version
    src
    date
    ;

  npmDeps = importNpmLock {
    package = builtins.fromJSON _sources.error-pages."package.json";
    packageLock = builtins.fromJSON _sources.error-pages."package-lock.json";
  };

  nativeBuildInputs = [
    nodejs
    importNpmLock.hooks.npmConfigHook
  ];

  buildPhase = ''
    runHook preBuild

    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    mv dist $out/share/error-pages

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/sapachev/error-pages";
    description = "Lightweight tool for creating static custom HTTP error pages";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.all;
  };
}
