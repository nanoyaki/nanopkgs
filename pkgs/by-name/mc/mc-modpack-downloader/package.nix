# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs_20,
  importNpmLock,

  nodejs ? nodejs_20,

  _sources,
}:

buildNpmPackage (finalAttrs: {
  inherit (_sources.mc-modpack-downloader) pname version src;
  inherit nodejs;

  npmDeps = importNpmLock {
    package = _sources.mc-modpack-downloader."package.json";
    packageLock = _sources.mc-modpack-downloader."package-lock.json";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildPhase = ''
    npx tsc --project tsconfig.json
  '';

  postInstall = ''
    mkdir -p $out/share
    cp -a dist $out/share/mc-modpack-downloader
    cp -a node_modules $out/share/mc-modpack-downloader

    makeWrapper "${lib.getExe finalAttrs.nodejs}" "$out/bin/mc-modpack-downloader" \
      --add-flags "--no-warnings $out/share/mc-modpack-downloader/main.js"
  '';

  meta = {
    description = "Script to pull minecraft mods from a set of APIs given a manifest file.";
    homepage = "https://github.com/newo-2001/MC-Modpack-Downloader";
    changelog = "https://github.com/newo-2001/MC-Modpack-Downloader/commits/master";
    maintainers = [ lib.maintainers.nanoyaki ];
    mainProgram = "mc-modpack-downloader";
    license = lib.licenses.mit;
    inherit (nodejs.meta) platforms;
  };
})
