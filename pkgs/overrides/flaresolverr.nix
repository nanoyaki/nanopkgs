# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  flaresolverr = prev.flaresolverr.overrideAttrs (
    finalAttrs: _: {
      pname = "flaresolverr";
      version = "3.4.6";

      src = final.fetchgit {
        url = "https://github.com/FlareSolverr/FlareSolverr.git";
        rev = "v${finalAttrs.version}";
        fetchSubmodules = false;
        deepClone = false;
        leaveDotGit = false;
        sparseCheckout = [ ];
        sha256 = "sha256-DeFp76VwMGBAWOsI3S3jm1qNbPw554zJZfE7hotUedY=";
      };

      passthru.updateScript = final.nix-update-script { extraArgs = [ "-F" ]; };
    }
  );
}
