# SPDX-FileCopyrightText: diniamo <diniamo53@gmail.com>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildDotnetModule,
  fetchgit,
  dotnet-sdk_10,
  dotnet-aspnetcore_10,
  nixosTests,
  mediainfo,
  rhash,
  _experimental-update-script-combinators,
  nix-update-script,
  writeShellScript,
  replaceVars,
  avdump,
}:

buildDotnetModule (finalAttrs: {
  pname = "shoko";
  version = "0-unstable-2026-05-08";

  src = fetchgit {
    url = "https://github.com/ShokoAnime/ShokoServer.git";
    rev = "04e0aa78f40d4b5e2688f2ffe96b85420be06367";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-T1KjhPHF5vsCMLUOsFmOyjKMijIkOwgmJ7+XHvozuQ0=";
  };

  patches = [
    (replaceVars ./avdump.patch { inherit avdump; })
  ];

  dotnet-sdk = dotnet-sdk_10;
  dotnet-runtime = dotnet-aspnetcore_10;

  nugetDeps = ./deps.json;
  projectFile = "Shoko.CLI/Shoko.CLI.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=dev,tag=${finalAttrs.version}\"";
  dotnetFlags = "/p:TargetFramework=net10.0";

  executables = [ "Shoko.CLI" ];
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${mediainfo}/bin"
  ];
  runtimeDeps = [ rhash ];

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        extraArgs = [
          "--version=branch"
          "--src-only"
          "-F"
        ];
      })
      (writeShellScript "fetch-deps.sh" ''
        $(nix-build -A shoko.passthru.fetch-deps) "pkgs/by-name/sh/shoko/deps.json"
      '')
    ];

    tests.shoko = nixosTests.shoko;
  };

  meta = {
    homepage = "https://github.com/ShokoAnime/ShokoServer";
    changelog = "https://github.com/ShokoAnime/ShokoServer/releases/tag/v${finalAttrs.version}";
    description = "Backend for the Shoko anime management system";
    license = lib.licenses.mit;
    mainProgram = "Shoko.CLI";
    # maintainers = [ lib.maintainers.diniamo ];
    inherit (dotnet-sdk_10.meta) platforms;
  };
})
