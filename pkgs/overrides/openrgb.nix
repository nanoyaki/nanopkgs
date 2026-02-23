# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  openrgb = prev.openrgb.overrideAttrs (prevAttrs: {
    pname = "openrgb";
    version = "release_candidate_1.0rc2-unstable-2026-02-22";

    src = final.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "f33a7ba8708190f1a08b9118d88fb8d82571eadf";
      hash = "sha256-U9bLmNCca/Dzw40pAZaix6TteMxRbDJxMacBHRQzZKU=";
    };

    patches = [ ];

    postPatch = ''
      patchShebangs scripts/build-udev-rules.sh
      substituteInPlace scripts/build-udev-rules.sh \
        --replace-fail "/usr/bin/env chmod" "${final.lib.getExe' final.coreutils "chmod"}"
    '';

    passthru = prevAttrs.passthru // {
      updateScript = final.nix-update-script {
        extraArgs = [
          "-F"
          "--version=branch"
        ];
      };
    };
  });
}
