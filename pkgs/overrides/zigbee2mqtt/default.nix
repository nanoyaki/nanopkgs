# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "zigbee2mqtt";
      version = "2.8.0-unstable-2026-02-01";

      src = final.fetchgit {
        url = "https://github.com/Koenkk/zigbee2mqtt.git";
        rev = "b0b02c30b2e58c94043298c14848c90a0f74a24a";
        fetchSubmodules = false;
        deepClone = false;
        leaveDotGit = false;
        sparseCheckout = [ ];
        sha256 = "sha256-O4jTVZ/9mvv6SKQ3Wrs8AcGvHoxuUjNwkHEaZkY9kBM=";
      };

      pnpmDeps = final.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = final.pnpm_9;
        fetcherVersion = 1;
        hash = "sha256-USpzlTtNlRI+xOJ37ZEohjNjtSBrq+bIqTNFH1IpObE=";
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
