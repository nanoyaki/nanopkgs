# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  zigbee2mqtt = prev.zigbee2mqtt.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "zigbee2mqtt";
      version = "2.7.1-unstable-2025-12-07";

      src = final.fetchgit {
        url = "https://github.com/Koenkk/zigbee2mqtt.git";
        rev = "8916fb7b50836627030915962f07c181fc1d1e8d";
        fetchSubmodules = false;
        deepClone = false;
        leaveDotGit = false;
        sparseCheckout = [ ];
        sha256 = "sha256-Es0HyIyiWA4Um0IldglZHgGF1VCD9O9kFXaxiLqXOEo=";
      };

      pnpmDeps = final.pnpm_9.fetchDeps {
        inherit (finalAttrs) pname version src;
        fetcherVersion = 1;
        hash = "sha256-XHDSjjYt/wbCdafLQ73dxDD+1ClbFtI7NejS9h5SNmE=";
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
