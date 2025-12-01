# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  name,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = name;
  version = "0-unstable-2025-11-28";

  src = fetchFromGitHub {
    owner = "stashapp";
    repo = "CommunityScrapers";
    rev = "f953b54196f12cbd1ee0b879e38fa65fff3de15d";
    hash = "sha256-Vbxe9Y3QChZ4tZ2timCQzdDFf1FcybRHv+hHfk42l94=";
  };

  pythonDeps = [ ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/scrapers/${finalAttrs.pname}
    cp -f $src/scrapers/${finalAttrs.pname}.yml $out/scrapers/${finalAttrs.pname}/${finalAttrs.pname}.yml

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
    ];
  };
})
