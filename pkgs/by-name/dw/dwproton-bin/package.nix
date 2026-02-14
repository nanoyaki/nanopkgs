# SPDX-FileCopyrightText: 2026 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  proton-ge-bin,
  fetchzip,
  writeScript,

  steamDisplayName ? "DWProton",
}:

proton-ge-bin.overrideAttrs (
  finalAttrs: _: {
    pname = "dwproton-bin";
    version = "10.0-17";

    src = fetchzip {
      url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-${finalAttrs.version}/dwproton-${finalAttrs.version}-x86_64.tar.xz";
      hash = "sha256-cP5GiEkbyO5GrK46h8HQwy/x0WTNKRII4k1JOMJlhgA=";
    };

    preFixup = ''
      substituteInPlace $steamcompattool/compatibilitytool.vdf \
        --replace-fail \
          '"display_name" "dwproton-${finalAttrs.version}-x86_64"' \
          '"display_name" "${steamDisplayName}"'
    '';

    passthru.updateScript = writeScript "update-dwproton" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq nix-update
      # shellcheck disable=SC1008
      repo="https://dawn.wine/api/v1/repos/dawn-winery/dwproton"
      version="$(
        curl -X 'GET' \
          "$repo"'/releases?draft=false&pre-release=false&limit=1' \
          -H 'accept: application/json' \
        | jq -r '.[0].tag_name'
      )"

      nix-update -F dwproton-bin --version="''${version##dwproton\-}"
    '';

    meta.maintainers = [ lib.maintainers.nanoyaki ];
  }
)
