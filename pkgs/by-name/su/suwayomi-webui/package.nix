# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchYarnDeps,
  yarnConfigHook,
  nodejs_22,
  husky,
  tsx,
  _experimental-update-script-combinators,
  nix-update-script,

  nodejs ? nodejs_22,

  _sources,
  _versions,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (_sources.suwayomi-webui) pname version src;
  inherit (_versions.suwayomi-webui) revision;

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = _versions.suwayomi-webui.yarnHash;
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
    (nix-update-script { })
    {
      command = [
        ./update-rev.sh
        finalAttrs.src.rev
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
