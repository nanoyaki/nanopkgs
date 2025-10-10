# SPDX-FileCopyrightText: 2025 Hana Kretzer <contact@nanoyaki.space>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchNpmDeps,
  nodejs,
  npmHooks,

  _sources,
  _versions,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (_sources.error-pages)
    pname
    version
    src
    date
    ;

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = _versions.error-pages.npmDepsHash;
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
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
})
