# SPDX-FileCopyrightText: diniamo <diniamo53@gmail.com>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchgit,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  shoko,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shoko-webui";
  version = "2.5.3-dev.0-unstable-2026-02-20";

  src = fetchgit {
    url = "https://github.com/ShokoAnime/Shoko-Webui.git";
    rev = "f9392c10d0c943efc3769917c1538e3672c79ae5";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-1Uzoix1T/3w+d75LwR9y7/WbahzhabMD/URgKwlTrJQ=";
  };

  # Avoid requiring git as a build time dependency. It's used for version
  # checking in the updater, which shouldn't be used if the webui is managed
  # declaratively anyway.
  patches = [ ./no-commit-hash.patch ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-UvPk+r1XjnsasMPNIQouZnyHodPnq4oaiFvCIlM4fmU=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
    ];
  };

  meta = {
    homepage = "https://github.com/ShokoAnime/Shoko-WebUI";
    changelog = "https://github.com/ShokoAnime/Shoko-WebUI/releases/tag/v${finalAttrs.version}";
    description = "Web-based frontend for the Shoko anime management system";
    maintainers = with lib.maintainers; [
      diniamo
      nanoyaki
    ];
    inherit (shoko.meta) license platforms;
  };
})
