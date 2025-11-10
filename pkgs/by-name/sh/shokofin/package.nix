# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  buildDotnetModule,
  dotnet-sdk_9,
  dotnet-aspnetcore_9,
  lib,
  nix-update-script,
  _experimental-update-script-combinators,

  _sources,
  _versions,
}:

buildDotnetModule (finalAttrs: {
  inherit (_sources.shokofin)
    pname
    src
    date
    ;

  version = _versions.shokofin._version;

  dotnet-sdk = dotnet-sdk_9;
  dotnet-runtime = dotnet-aspnetcore_9;

  nugetDeps = ./deps.json;
  projectFile = "Shokofin/Shokofin.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=dev,tag=${finalAttrs.version}\"";

  executables = [ ];

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script { })
    finalAttrs.fetch-deps
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
