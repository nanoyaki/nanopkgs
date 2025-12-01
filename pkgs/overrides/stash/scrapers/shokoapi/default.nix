# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  fetchFromGitHub,
  python313Packages,
  replaceVars,
  configJSON ? ./default.json,
  stashScrapers,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "ShokoAPI";
  version = "0-unstable-2025-11-28";

  src = fetchFromGitHub {
    owner = "stashapp";
    repo = "CommunityScrapers";
    rev = "f953b54196f12cbd1ee0b879e38fa65fff3de15d";
    hash = "sha256-Vbxe9Y3QChZ4tZ2timCQzdDFf1FcybRHv+hHfk42l94=";
  };

  pythonDeps = [
    python313Packages.requests
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/scrapers
    cp -a ${stashScrapers.py-common}/scrapers/py_common $out/scrapers
    cp -a scrapers/ShokoAPI $out/scrapers
    cp -f ${replaceVars ./config.py.template { path = configJSON; }} $out/scrapers/ShokoAPI/config.py

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
    ];
  };
}
