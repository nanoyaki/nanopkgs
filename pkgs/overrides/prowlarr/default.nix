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
      version = "2.3.7.5365";

      src = final.applyPatches {
        src = final.fetchgit {
          url = "https://github.com/Prowlarr/Prowlarr.git";
          rev = "v${finalAttrs.version}";
          fetchSubmodules = false;
          deepClone = false;
          leaveDotGit = false;
          sparseCheckout = [ ];
          sha256 = "sha256-NWlf3KUBnwu9I0Z4kNiRi3Ade7srNsB5qQJJ9/ril9E=";
        };

        postPatch = ''
          mv src/NuGet.config NuGet.Config
        '';
      };

      buildInputs = nugetDeps ++ prevAttrs.buildInputs;

      yarnOfflineCache = final.fetchYarnDeps {
        yarnLock = "${finalAttrs.src}/yarn.lock";
        hash = "sha256-FYLfOR5gm9lg1F8RGyDN6MkFAcaxWIdIxd/IDBVUMUQ=";
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
