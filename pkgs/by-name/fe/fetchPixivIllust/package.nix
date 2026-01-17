# SPDX-FileCopyrightText: 2026 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  curl,
  jq,
  cacert,
}:

{
  pixivId,
  pages ? [ 0 ],
  allPages ? false,
  hash ? "",
}:

let
  parsedId = if lib.isInt pixivId then toString pixivId else pixivId;

  pagesScript =
    if allPages then
      builtins.warn (
        "It's not recommended to use allPages."
        + " Using it may lead to irreproducible behaviour if the author"
        + " of the illustration decides to modify the page count."
      ) "pages=$(seq 0 $((pageCount - 1)))"
    else
      "pages=(${lib.concatMapStringsSep " " (page: "\"${toString page}\"") pages})";
in

stdenvNoCC.mkDerivation {
  name = "illust-${parsedId}-pages-${lib.concatMapStringsSep "-" toString pages}";

  nativeBuildInputs = [
    curl
    jq
  ];

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  dontUnpack = true;
  dontConfigure = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    id="${parsedId}"

    # Retrieve metadata
    metadata="$(
      curl --fail -S \
        -H "Accept: application/json" \
        -H "Referer: https://www.pixiv.net/artworks/$id" \
        "https://www.pixiv.net/ajax/illust/$id"
    )"

    # Verify that page numbers don't exceed page count
    pageCount="$(echo "$metadata" | jq -r '.body.pageCount')"
    ${pagesScript}

    for page in $pages; do
      if (( $page >= $pageCount )); then
        >&2 echo "Page number $page exceeds the total page count of $pageCount page(s)."
        exit 1
      fi
    done

    artworkUrl="$(echo "$metadata" | jq -r '.body.urls.original')"

    for page in $pages; do
      local url="''${artworkUrl/_p0/_p$page}"
      curl --fail -S \
        -H "Referer: https://www.pixiv.net/" \
        "$url" -O
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    [[ ''${#pages[@]} > 1 ]] && mkdir -p $out
    cp "${parsedId}"* $out

    runHook postInstall
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = hash;
}
