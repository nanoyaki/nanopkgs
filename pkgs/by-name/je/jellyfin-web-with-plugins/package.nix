# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  runCommand,
  jellyfin-web,
  inPlayerEpisodePreview ? true,
  introSkipper ? true,
  nix-update-script,
}:

let

  introSkipperScript = ''<script src=\"configurationpage?name=skip-intro-button.js\"></script>'';
  inPlayerEpisodePreviewScript =
    ''<script plugin="InPlayerEpisodePreview" ''
    + ''version="${pkg.inPlayerEpisodePreview.version}" ''
    + ''src="/InPlayerPreview/ClientScript"></script>'';

  pkg = {
    inPlayerEpisodePreview = stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "InPlayerEpisodePreview";
      version = "1.5.0.0";

      src = fetchFromGitHub {
        owner = "Namo2";
        repo = "InPlayerEpisodePreview";
        rev = finalAttrs.version;
      };

      passthru.updateScript = nix-update-script {
        extraArgs = [
          "--src-only"
          "-F"
        ];
      };
    });
  };
in

(runCommand "jellyfin-web-with-plugins" { } ''
  shopt -s extglob

  mkdir -p $out/share/jellyfin-web
  cp -a ${jellyfin-web}/share/jellyfin-web/!(index.html) $out/share/jellyfin-web
  install -m600 ${jellyfin-web}/share/jellyfin-web/index.html index.html

  ${lib.optionalString introSkipper ''
    sed -i "s#</head>#${introSkipperScript}</head>#" \
      index.html
  ''}

  ${lib.optionalString inPlayerEpisodePreview ''
    sed -i 's#</body>#${inPlayerEpisodePreviewScript}</body>#' \
      index.html
  ''}

  install -m444 index.html $out/share/jellyfin-web/index.html
'')
// pkg
