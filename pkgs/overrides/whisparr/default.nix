# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  whisparr = prev.whisparr.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "whisparr";
      version = "3.1.0.2111";

      src = final.fetchurl {
        url = "https://whisparr.servarr.com/v1/update/eros/updatefile?version=${finalAttrs.version}&os=linux&runtime=netcore&arch=x64";
        name = "whisparr-src-${finalAttrs.version}.tar.gz";
        sha256 = "sha256-hyrgLB3+36lgYTzoycsusAd/dz41Jfl5WoJf5izOaEA=";
      };

      passthru = prevAttrs.passthru // {
        updateScript = final._experimental-update-script-combinators.sequence [
          [
            ./update-version.sh
            "pkgs/overrides/whisparr/default.nix"
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
