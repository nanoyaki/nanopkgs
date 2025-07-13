# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildDotnetModule,
  dotnet-sdk_8,
  dotnet-aspnetcore_8,
  nix-update-script,
  _experimental-update-script-combinators,

  _sources,
}:

buildDotnetModule (finalAttrs: {
  inherit (_sources.luarenamer) pname src;
  version = lib.removePrefix "v" _sources.luarenamer.version;

  patches = [
    ./nozip.patch
  ];

  dotnet-sdk = dotnet-sdk_8;
  dotnet-runtime = dotnet-aspnetcore_8;

  nugetDeps = ./deps.json;
  projectFile = "LuaRenamer/LuaRenamer.csproj";

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script { })
    finalAttrs.fetch-deps
  ];

  meta = {
    homepage = "https://github.com/Mik1ll/LuaRenamer";
    changelog = "https://github.com/Mik1ll/LuaRenamer/releases/tag/${finalAttrs.version}";
    description = "Plugin for Shoko Server that allows users to rename their collection via an Lua 5.4 interface.";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nanoyaki ];
    inherit (dotnet-sdk_8.meta) platforms;
  };
})
