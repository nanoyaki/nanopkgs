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
  version = "6.0.4-dev.2-unstable-2026-02-17";

  src = fetchgit {
    url = "https://github.com/ShokoAnime/Shokofin.git";
    rev = "c4b7624e3691f59143c22a3c8de3d5547e108c8b";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-xJTR8/I83WuSGN59fA0NlKWZMeh0gobpXKrc+F/PgeM=";
  };

  dotnet-sdk = dotnet-sdk_9;
  dotnet-runtime = dotnet-aspnetcore_9;

  nugetDeps = ./deps.json;
  projectFile = "Shokofin/Shokofin.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=dev,tag=${finalAttrs.version}\"";
  dotnetInstallFlags = "-f net9.0";

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
