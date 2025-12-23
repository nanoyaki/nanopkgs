# SPDX-FileCopyrightText: diniamo <diniamo53@gmail.com>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  fetchgit,
  nodejs,
  pnpm,
  # lib,
  shoko,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shoko-webui";
  version = "2.4.0-dev.8-unstable-2025-12-22";

  src = fetchgit {
    url = "https://github.com/ShokoAnime/Shoko-Webui.git";
    rev = "4fddd2b2a51c3d7916f541a5756b97e6b252cf51";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-/inw4dp2BOErkz+BUX6BVmpPjHcNlP8aTga+q6MJ7DY=";
  };

  # Avoid requiring git as a build time dependency. It's used for version
  # checking in the updater, which shouldn't be used if the webui is managed
  # declaratively anyway.
  patches = [ ./no-commit-hash.patch ];

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-aCBiFteBebq/kmeV5GIlp3yPeaE99U+WKokvYQAwZzg=";
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
    # maintainers = [ lib.maintainers.diniamo ];
    inherit (shoko.meta) license platforms;
  };
})
