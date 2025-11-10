# SPDX-FileCopyrightText: diniamo <diniamo53@gmail.com>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  buildDotnetModule,
  dotnet-sdk_8,
  dotnetCorePackages,
  nixosTests,
  lib,
  mediainfo,
  rhash,
  nix-update-script,

  _sources,
  _versions,
}:

buildDotnetModule (finalAttrs: {
  inherit (_sources.shoko)
    pname
    src
    date
    ;

  version = _versions.shoko._version;

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

  executables = [ "Shoko.CLI" ];
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${mediainfo}/bin"
  ];
  runtimeDeps = [ rhash ];

  passthru = {
    updateScript = nix-update-script { };
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
