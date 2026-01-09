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
  version = "20251230.01-unstable-2026-01-08";
  revision = "2947";

  src = fetchgit {
    url = "https://github.com/Suwayomi/Suwayomi-WebUI.git";
    rev = "9642c85007d6b62d0e2262bc5b6773990d9a0b3b";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-mCM9BHcGjTmK5ZHA+aH+530AUBx98wn0WBJTi0s+RO0=";
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
