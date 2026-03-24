# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  openrgb = prev.openrgb.overrideAttrs (prevAttrs: {
    pname = "openrgb";
    version = "release_candidate_1.0rc2-unstable-2026-03-23";

    src = final.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "984c18cb11693990619cc03c075d39ce16666bea";
      hash = "sha256-8dD+nG8Ke3Wa/VXlvsWb5VekD4x3qhJPm49boXGuNIw=";
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
