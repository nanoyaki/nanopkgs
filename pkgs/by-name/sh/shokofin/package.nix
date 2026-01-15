# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildDotnetModule,
  fetchgit,
  dotnet-sdk_9,
  dotnet-aspnetcore_9,
  nix-update-script,
  _experimental-update-script-combinators,
  writeShellScript,
}:

buildDotnetModule (finalAttrs: {
  pname = "shokofin";
  version = "6.0.0-dev.2-unstable-2026-01-14";

  src = fetchgit {
    url = "https://github.com/ShokoAnime/Shokofin.git";
    rev = "1b75ab4fc631c6eb191f599b3c9e77b218a54baa";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-4MTeudkZ3N+YtyApztF97u8zNc+G4euZV2GXtGAXKfQ=";
  };

  dotnet-sdk = dotnet-sdk_9;
  dotnet-runtime = dotnet-aspnetcore_9;

  nugetDeps = ./deps.json;
  projectFile = "Shokofin/Shokofin.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=dev,tag=${finalAttrs.version}\"";

  executables = [ ];

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [
        "--version=branch"
        "--src-only"
        "-F"
      ];
    })
    (writeShellScript "fetch-deps.sh" ''
      $(nix-build -A shokofin.passthru.fetch-deps) "pkgs/by-name/sh/shokofin/deps.json"
    '')
  ];

  meta = {
    homepage = "https://github.com/ShokoAnime/Shokofin";
    changelog = "https://github.com/ShokoAnime/Shokofin/releases/tag/v${finalAttrs.version}";
    description = "Shoko anime Jellyfin integration plugin";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nanoyaki ];
    inherit (dotnet-sdk_9.meta) platforms;
  };
})
