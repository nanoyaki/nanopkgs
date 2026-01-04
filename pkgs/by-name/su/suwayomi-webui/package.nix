# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchgit,
  fetchYarnDeps,
  yarnConfigHook,
  nodejs_22,
  husky,
  tsx,
  _experimental-update-script-combinators,
  nix-update-script,

  nodejs ? nodejs_22,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "suwayomi-webui";
  version = "20251230.01-unstable-2026-01-02";
  revision = "2938";

  src = fetchgit {
    url = "https://github.com/Suwayomi/Suwayomi-WebUI.git";
    rev = "2e4d2fcccad4a66beeb10bb8da83e2846058e702";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-yCOXHNoOSnD3cJi6RADZJvAUMr3GEMbRowvySBkms80=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-UUp56kPe/RErsp3nMEpFDf7/rgrICfvur7CDIxTIFig=";
  };

  nativeBuildInputs = [
    yarnConfigHook

    nodejs
    husky
    tsx
  ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "project" "suwayomi-webui" \
      --replace-fail "22.12.0" "${nodejs.version}"
  '';

  buildPhase = ''
    runHook preBuild

    yarn --offline setup-env-files

    patchShebangs node_modules/vite/bin/vite.js
    node_modules/vite/bin/vite.js build

    yarn --offline build-md5
    echo "r${finalAttrs.revision}" > build/revision

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -a build $out
    mv buildZip/md5sum $out

    runHook postInstall
  '';

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [
        "--version=branch"
        "-F"
      ];
    })
    {
      command = [
        ./update-rev.sh
        finalAttrs.src.rev
        "pkgs/by-name/su/suwayomi-webui/package.nix"
      ];
    }
  ];

  meta = {
    description = "The client for Suwayomi-Server";
    homepage = "https://github.com/Suwayomi/Suwayomi-WebUI";
    downloadPage = "https://github.com/Suwayomi/Suwayomi-WebUI/releases/";
    changelog = "https://github.com/Suwayomi/Suwayomi-WebUI/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    inherit (nodejs_22.meta) platforms;
    maintainers = with lib.maintainers; [
      ratcornu
      nanoyaki
    ];
  };
})
