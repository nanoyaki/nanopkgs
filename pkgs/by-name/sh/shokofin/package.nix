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
  shokoPluginPostInstallHook,
}:

buildDotnetModule (finalAttrs: {
  pname = "shokofin";
  version = "5.0.6-dev.18-unstable-2025-12-19";

  src = fetchgit {
    url = "https://github.com/ShokoAnime/Shokofin.git";
    rev = "9381808fd0cb5b8da24def403d8f278de9cee818";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-U3dC1VpTOc9485c+6ljwA7WZfN1pOaULxpPGg6sMW0E=";
  };

  dotnet-sdk = dotnet-sdk_9;
  dotnet-runtime = dotnet-aspnetcore_9;

  nugetDeps = ./deps.json;
  projectFile = "Shokofin/Shokofin.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=dev,tag=${finalAttrs.version}\"";

  executables = [ ];

  nativeBuildInputs = [
    shokoPluginPostInstallHook
  ];

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
