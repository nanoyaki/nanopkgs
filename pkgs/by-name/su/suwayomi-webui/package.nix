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
  version = "20251230.01-unstable-2026-03-21";
  revision = "3060";

  src = fetchgit {
    url = "https://github.com/Suwayomi/Suwayomi-WebUI.git";
    rev = "d738de2c61105a0fbeec57d1ce940492337b608c";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-sEGO44+5TnxhB6527BSZVu0D3Ntk/61pk5YP1yIosyc=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-uol1A0MFyNdVLZ1xNho0jbloyPjnGb0HN4HjREhxJFA=";
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
