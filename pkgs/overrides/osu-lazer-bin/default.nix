# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  osu-lazer-bin = prev.osu-lazer-bin.override {
    appimageTools = prev.appimageTools // {
      wrapType2 =
        prevAttrs:
        prev.appimageTools.wrapType2 (
          prevAttrs
          // rec {
            pname = "osu-lazer-bin";
            version = "2026.406.0-lazer";

            src = final.fetchurl {
              url = "https://github.com/ppy/osu/releases/download/${version}/osu.AppImage";
              sha256 = "sha256-RKKhf193BYF7dYL1x4gF2+Kl2xHuWZ/WMYBk4M/x8S0=";
            };

            passthru.updateScript = final._experimental-update-script-combinators.sequence [
              [
                ./update-version.sh
                "pkgs/overrides/osu-lazer-bin/default.nix"
              ]
              (final.nix-update-script {
                extraArgs = [
                  "-F"
                  "--version=skip"
                ];
              })
            ];
          }
        );
    };
  };
}
