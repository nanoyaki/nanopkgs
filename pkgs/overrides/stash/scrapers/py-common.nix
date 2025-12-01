# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  stashDataDir ? "/var/lib/stash",
}:

stdenvNoCC.mkDerivation {
  pname = "py_common";
  version = "0-unstable-2025-11-28";

  src = fetchFromGitHub {
    owner = "stashapp";
    repo = "CommunityScrapers";
    rev = "f953b54196f12cbd1ee0b879e38fa65fff3de15d";
    hash = "sha256-Vbxe9Y3QChZ4tZ2timCQzdDFf1FcybRHv+hHfk42l94=";
  };

  postPatch = ''
    substituteInPlace scrapers/py_common/config.py \
      --replace-fail 'configs[0]' \
        'Path("${stashDataDir}/" + Path(paths[len(paths) - 1]).absolute().parent.name + "-config.ini").absolute()'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/scrapers
    cp -a scrapers/py_common $out/scrapers

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
    ];
  };
}
