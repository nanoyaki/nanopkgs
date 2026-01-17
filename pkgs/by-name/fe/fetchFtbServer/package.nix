# SPDX-FileCopyrightText: 2025-2026 Hana Kretzer <hanakretzer@gmail.com>
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
  apiKeyFile ? "",
  hash ? "",
}:

let
  keyFile =
    if apiKeyFile != "" then
      lib.throwIfNot (lib.types.path.check apiKeyFile)
        "apiKeyFile must be of type: ${lib.types.path.description}"
        apiKeyFile
    else
      apiKeyFile;
in

stdenvNoCC.mkDerivation {
  pname = pack;
  inherit version;

  nativeBuildInputs = [
    ftb-server-installer
    findutils
    cacert
  ];

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  buildPhase = ''
    runHook preBuild

    ftb-server-downloader \
      -auto \
      -force \
      -provider ftb \
      ${
        lib.optionalString (
          apiKey != ""
        ) "-apikey ${builtins.warn "Using apiKey is deprecated. Use apiKeyFile instead." apiKey}"
      } \
      ${lib.optionalString (keyFile != "") "-apikey \"$(cat ${keyFile})\""} \
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
  outputHash = hash;
}
