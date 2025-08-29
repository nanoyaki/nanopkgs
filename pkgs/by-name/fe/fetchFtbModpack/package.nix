# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  mc-modpack-downloader,
  findutils,
  cacert,
}:

{
  modpackId,
  versionId,
  hash ? null,
}:

stdenvNoCC.mkDerivation {
  pname = modpackId;
  version = versionId;

  src = ./.;

  nativeBuildInputs = [
    mc-modpack-downloader
    findutils
    cacert
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  buildPhase = ''
    runHook preBuild

    mc-modpack-downloader ftb \
      --modpack-id "${modpackId}" \
      --modpack-version "${versionId}" \
      -o $out

    rm latest.log package.nix

    runHook postBuild
  '';

  fixupPhase = ''
    runHook preFixup

    find $out -exec touch -d @0 {} +

    runHook postFixup
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash =
    if hash == null then
      builtins.warn "hash unspecified, defaulting to `lib.fakeHash`" lib.fakeHash
    else
      hash;
}
