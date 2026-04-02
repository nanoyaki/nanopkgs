# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "zigbee2mqtt";
      version = "2.9.2-unstable-2026-04-01";

      src = final.fetchgit {
        url = "https://github.com/Koenkk/zigbee2mqtt.git";
        rev = "2b485a98c5f9c879e1e9b80ffae3c7a84b0dce8d";
        fetchSubmodules = false;
        deepClone = false;
        leaveDotGit = false;
        sparseCheckout = [ ];
        sha256 = "sha256-LdrsHOeRXeNccpf1UNg20y82M75PGt070zVbmQYYsVg=";
      };

      pnpmDeps = final.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = final.pnpm_9;
        fetcherVersion = 1;
        hash = "sha256-8ioe9/gSI9u9ehrnj3L1j+vPS9p+nJGs2d8TdZTEsk4=";
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
