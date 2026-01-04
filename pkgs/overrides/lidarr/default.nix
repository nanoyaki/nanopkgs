# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  lidarr = prev.lidarr.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "lidarr";
      version = "3.1.1.4900";

      src = final.fetchurl {
        url = "https://lidarr.servarr.com/v1/update/develop/updatefile?version=${finalAttrs.version}&os=linux&runtime=netcore&arch=x64";
        name = "lidarr-src-${finalAttrs.version}.tar.gz";
        sha256 = "sha256-uApfgiD/5cqXH6fg9i3Qj3Oasoe3vyJ00EkcxR/CEnE=";
      };

      passthru = prevAttrs.passthru // {
        updateScript = final._experimental-update-script-combinators.sequence [
          [
            ./update-version.sh
            "pkgs/overrides/lidarr/default.nix"
          ]
          (final.nix-update-script {
            extraArgs = [
              "-F"
              "--version=skip"
            ];
          })
        ];
      };
    }
  );
}
