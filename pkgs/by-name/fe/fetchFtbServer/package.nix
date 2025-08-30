# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  ftb-server-installer,
  findutils,
  cacert,
}:

{
  pack,
  version,
  apiKey ? "",
  hash ? null,
}:

stdenvNoCC.mkDerivation {
  pname = pack;
  inherit version;

  src = ./.;

  nativeBuildInputs = [
    ftb-server-installer
    findutils
    cacert
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  postPatch = ''
    rm package.nix
  '';

  buildPhase = ''
    runHook preBuild

    ftb-server-downloader \
      -auto \
      -force \
      -provider ftb \
      ${lib.optionalString (apiKey != "") "-apikey ${apiKey}"} \
      -pack "${pack}" \
      -version "${version}" \
      -threads $NIX_BUILD_CORES \
      -skip-modloader \
      -no-java \
      -no-colours \
      -verbose \
      -validate \
      -dir $out

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
