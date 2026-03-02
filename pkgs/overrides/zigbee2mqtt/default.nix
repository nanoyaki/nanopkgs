# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "zigbee2mqtt";
      version = "2.9.1-unstable-2026-03-02";

      src = final.fetchgit {
        url = "https://github.com/Koenkk/zigbee2mqtt.git";
        rev = "85875aee27caa005946bb5a446080461a0d2fc33";
        fetchSubmodules = false;
        deepClone = false;
        leaveDotGit = false;
        sparseCheckout = [ ];
        sha256 = "sha256-PsgQ1/h9YCQNV58PB7o3CQyfuOXzU878I9qIfozX02w=";
      };

      pnpmDeps = final.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = final.pnpm_9;
        fetcherVersion = 1;
        hash = "sha256-MM184JsFVGqOALyQjCyR3QnHqHoQr39lnodq5v4cXAQ=";
      };

      passthru = prevAttrs.passthru // {
        updateScript = final.nix-update-script {
          extraArgs = [
            "-F"
            "--version=branch"
          ];
        };
      };
    }
  );
}
