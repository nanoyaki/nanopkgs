# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  openrgb = prev.openrgb.overrideAttrs (prevAttrs: {
    pname = "openrgb";
    version = "release_candidate_1.0rc2-unstable-2026-02-13";

    src = final.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "880dc1450d0bcd27eec2bc9526590ffb40e87e78";
      hash = "sha256-TsMOujVI178r887IIh7fTPJRKxT3VIi965mipZcimzI=";
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
