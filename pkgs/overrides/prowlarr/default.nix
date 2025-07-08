# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  prowlarr = prev.prowlarr.overrideAttrs (
    finalAttrs: prevAttrs:
    let
      inherit (final) lib;

      nugetDeps = builtins.map final.dotnetCorePackages.fetchNupkg (lib.importJSON ./deps.json);
    in
    final.dotnetCorePackages.addNuGetDeps
      {
        nugetDeps = ./deps.json;
        overrideFetchAttrs = old: rec {
          runtimeIds = map (system: final.dotnetCorePackages.systemToDotnetRid system) old.meta.platforms;
          buildInputs =
            old.buildInputs
            ++ lib.concatLists (lib.attrValues (lib.getAttrs runtimeIds final.dotnet-sdk_8.targetPackages));
        };
      }
      {
        inherit (final._sources.prowlarr) pname;
        version = lib.removePrefix "v" final._sources.prowlarr.version;

        src = final.applyPatches {
          inherit (final._sources.prowlarr) src;

          postPatch = ''
            mv src/NuGet.config NuGet.Config
          '';
        };

        buildInputs =
          nugetDeps
          ++ (lib.concatLists (
            lib.attrValues (
              lib.getAttrs (map (
                system: final.dotnetCorePackages.systemToDotnetRid system
              ) finalAttrs.meta.platforms) final.dotnet-sdk_8.targetPackages
            )
          ));

        dotnetFlags =
          (lib.filter (
            flag:
            flag != "--property:AssemblyConfiguration=master"
            && flag != "--property:AssemblyVersion=${prevAttrs.version}"
          ) prevAttrs.dotnetFlags)
          ++ [
            "--property:AssemblyConfiguration=develop"
            "--property:AssemblyVersion=${finalAttrs.version}"
          ];

        yarnOfflineCache = final.fetchYarnDeps {
          yarnLock = "${finalAttrs.src}/yarn.lock";
          hash = final._versions.prowlarr.yarnHash;
        };
      }
      finalAttrs
  );
}
