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
      pname = "prowlarr";
      version = "2.3.1.5238";

      src = final.applyPatches {
        src = final.fetchgit {
          url = "https://github.com/Prowlarr/Prowlarr.git";
          rev = "v${finalAttrs.version}";
          fetchSubmodules = false;
          deepClone = false;
          leaveDotGit = false;
          sparseCheckout = [ ];
          sha256 = "sha256-v6/q2oxXPsN0Yrie1cDk9YwtSHfos1oulYGdqBeUaMs=";
        };

        postPatch = ''
          mv src/NuGet.config NuGet.Config
        '';
      };

      buildInputs = nugetDeps ++ prevAttrs.buildInputs;

      yarnOfflineCache = final.fetchYarnDeps {
        yarnLock = "${finalAttrs.src}/yarn.lock";
        hash = "sha256-QVyjo/Zshy+61qocGKa3tZS8gnHvvVqenf79FkiXDBM=";
      };

      passthru = prevAttrs.passthru // {
        updateScript = final._experimental-update-script-combinators.sequence [
          (final.nix-update-script { extraArgs = [ "-F" ]; })
          (final.writeShellScript "fetch-deps.sh" ''
            $(nix-build -A prowlarr.fetch-deps) "pkgs/overrides/prowlarr/deps.json"
          '')
        ];
      };
    }
  );
}
