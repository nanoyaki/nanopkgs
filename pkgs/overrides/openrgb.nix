# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  openrgb = prev.openrgb.overrideAttrs (prevAttrs: {
    pname = "openrgb";
    version = "release_candidate_1.0rc2-unstable-2025-12-19";

    src = final.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "e631ca9f11c14a1ca5eb521b33dc7476828bfd95";
      hash = "sha256-1+1SM9BzM3TrMeUBmugbcIKk0fWWmd6/U2wCG/5eoSA=";
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
