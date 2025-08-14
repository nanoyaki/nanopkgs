# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  runCommand,
  jellyfin-web,
  inPlayerEpisodePreview ? true,
  introSkipper ? true,

  _versions,
}:

let
  introSkipperScript = ''<script src=\"configurationpage?name=skip-intro-button.js\"></script>'';
  inPlayerEpisodePreviewScript =
    ''<script plugin="InPlayerEpisodePreview" ''
    + ''version="${_versions.inPlayerEpisodePreview.version}" ''
    + ''src="/InPlayerPreview/ClientScript"></script>'';
in

runCommand "jellyfin-web-with-plugins" { src = jellyfin-web; } ''
  shopt -s extglob

  mkdir -p $out/share/jellyfin-web
  cp -a $src/share/jellyfin-web/!(index.html) $out/share/jellyfin-web
  install -m600 $src/share/jellyfin-web/index.html index.html

  ${lib.optionalString introSkipper ''
    sed -i "s#</head>#${introSkipperScript}</head>#" \
      index.html
  ''}

  ${lib.optionalString inPlayerEpisodePreview ''
    sed -i 's#</body>#${inPlayerEpisodePreviewScript}</body>#' \
      index.html
  ''}

  install -m444 index.html $out/share/jellyfin-web/index.html
''
