# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  python313Packages,
  replaceVars,
  configJSON ? ./default.json,
  stashScrapers,

  _sources,
}:

stdenvNoCC.mkDerivation {
  pname = "ShokoAPI";
  inherit (_sources.stash-scrapers) src version;

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
}
