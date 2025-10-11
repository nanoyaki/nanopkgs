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

    {
      inherit (final._sources.prowlarr) pname;
      version = lib.removePrefix "v" final._sources.prowlarr.version;

      src = final.applyPatches {
        inherit (final._sources.prowlarr) src;

        postPatch = ''
          mv src/NuGet.config NuGet.Config
        '';
      };

      buildInputs = nugetDeps ++ prevAttrs.buildInputs;

      yarnOfflineCache = final.fetchYarnDeps {
        yarnLock = "${finalAttrs.src}/yarn.lock";
        hash = final._versions.prowlarr._yarnHash;
      };
    }
  );
}
