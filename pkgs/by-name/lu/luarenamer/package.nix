# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildDotnetModule,
  fetchgit,
  dotnet-sdk_8,
  dotnet-aspnetcore_8,
  _experimental-update-script-combinators,
  nix-update-script,
  writeShellScript,
}:

buildDotnetModule (finalAttrs: {
  pname = "luarenamer";
  version = "5.9.0-compat";

  src = fetchgit {
    url = "https://github.com/Mik1ll/LuaRenamer.git";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-EyA7UzRy8YzBmhXiANfbTyfK3DVp/F7KpgxSkNs/B1g=";
  };

  patches = [
    ./nozip.patch
  ];

  dotnet-sdk = dotnet-sdk_8;
  dotnet-runtime = dotnet-aspnetcore_8;

  nugetDeps = ./deps.json;
  projectFile = "LuaRenamer/LuaRenamer.csproj";

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [
        "--src-only"
        "-F"
      ];
    })
    (writeShellScript "fetch-deps.sh" ''
      $(nix-build -A luarenamer.passthru.fetch-deps) "pkgs/by-name/lu/luarenamer/deps.json"
    '')
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
