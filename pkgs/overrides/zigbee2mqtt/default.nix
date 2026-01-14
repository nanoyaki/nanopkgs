# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "zigbee2mqtt";
      version = "2.7.2-unstable-2026-01-01";

      src = final.fetchgit {
        url = "https://github.com/Koenkk/zigbee2mqtt.git";
        rev = "3a49c95786c2fba749e7696aab4cc38e467d2c4c";
        fetchSubmodules = false;
        deepClone = false;
        leaveDotGit = false;
        sparseCheckout = [ ];
        sha256 = "sha256-eIuIWjLsjpvgIgnQC3opsSYc34GD5vLvPvO7DhKyVFA=";
      };

      pnpmDeps = final.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = final.pnpm_9;
        fetcherVersion = 1;
        hash = "sha256-HOYGJzcLyrvhhYnIIwhLiSiYyDdEob3+LNdlfmbspeQ=";
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
