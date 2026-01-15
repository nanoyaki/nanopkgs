# SPDX-FileCopyrightText: diniamo <diniamo53@gmail.com>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildDotnetModule,
  fetchgit,
  dotnet-sdk_8,
  dotnetCorePackages,
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
  version = "5.2.1-unstable-2026-01-14";

  src = fetchgit {
    url = "https://github.com/ShokoAnime/ShokoServer.git";
    rev = "ed8e9e61b2f19eff812fe11c2822832c3c7be24e";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-20A4Sq4ZkK0T7eYOPatv2PIiCXIjmR2dTN377WG8nlY=";
  };

  patches = [
    ./deps.patch
    (replaceVars ./avdump.patch { inherit avdump; })
  ];

  dotnet-sdk =
    with dotnetCorePackages;

    combinePackages [
      sdk_8_0
      sdk_9_0
    ];

  dotnet-runtime =
    with dotnetCorePackages;

    combinePackages [
      sdk_8_0.aspnetcore
      sdk_9_0.aspnetcore
    ];

  nugetDeps = ./deps.json;
  projectFile = "Shoko.CLI/Shoko.CLI.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=dev,tag=${finalAttrs.version}\"";
  dotnetInstallFlags = "-f net9.0";

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
    inherit (dotnet-sdk_8.meta) platforms;
  };
})
