# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  openrgb = prev.openrgb.overrideAttrs (prevAttrs: {
    pname = "openrgb";
    version = "release_candidate_1.0rc2-unstable-2025-12-13";

    src = final.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "b160bcf3fa0a2bd2cd3b1e9c2b6ae5852fe30772";
      hash = "sha256-wxiNi+rPaES0IK9YdE/zHZIfYGLR5HhQBBqPtPCWxNY=";
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
