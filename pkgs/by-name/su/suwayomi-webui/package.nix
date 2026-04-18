# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchgit,
  fetchYarnDeps,
  yarnConfigHook,
  nodejs_24,
  husky,
  tsx,
  _experimental-update-script-combinators,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "suwayomi-webui";
  version = "20251230.01-unstable-2026-04-17";
  revision = "3081";

  src = fetchgit {
    url = "https://github.com/Suwayomi/Suwayomi-WebUI.git";
    rev = "f6302fe3aa5d034f498b1d4f88d059e2282ff9ea";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-QldHeZyIodCCEWhSpvFn0YgXbQUyfVYCmZd06rUwzVY=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-Pcze/IdYfDyL8Tfwp4j1ovQMlaoJVT/IxJRK75jKxR0=";
  };

  nativeBuildInputs = [
    yarnConfigHook

    nodejs_24
    husky
    tsx
  ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "project" "suwayomi-webui"
  '';

  buildPhase = ''
    runHook preBuild

    yarn --offline setup-env-files

    patchShebangs node_modules/vite/bin/vite.js
    node_modules/vite/bin/vite.js build

    echo "r${finalAttrs.revision}" > build/revision
    yarn --offline build-md5

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/suwayomi-server
    cp -a build $out/share/suwayomi-webui
    mv buildZip/md5sum $out/share/suwayomi-server

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
    inherit (nodejs_24.meta) platforms;
    maintainers = with lib.maintainers; [
      ratcornu
      nanoyaki
    ];
  };
})
