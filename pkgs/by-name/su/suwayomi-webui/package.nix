# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  replaceVars,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs_22,
  zip,
  nix-update-script,

  _sources,
  _versions,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (_sources.suwayomi-webui) pname version src;
  inherit (_versions.suwayomi-webui) revision;

  patches = [
    (replaceVars ./version.patch {
      inherit (finalAttrs) revision;
      inherit (nodejs_22) version;
    })
  ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = _versions.suwayomi-webui.yarnHash;
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook

    nodejs_22
    zip
  ];

  postBuild = ''
    yarn --offline build-md5
    yarn --offline build-zip
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out/share -p
    cp buildZip/Suwayomi-WebUI-r${finalAttrs.revision}.zip $out/share/WebUI.zip

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

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
