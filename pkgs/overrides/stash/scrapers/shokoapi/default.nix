# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  python313Packages,
  replaceVars,
  configJSON ? ./default.json,

  _sources,
}:

stdenvNoCC.mkDerivation {
  pname = "ShokoAPI";
  inherit (_sources.stash-scrapers) src version;

  pythonDeps = [
    python313Packages.requests
  ];

  installPhase = ''
    mkdir -p $out/scrapers/ShokoAPI
    cp -r $src/scrapers/ShokoAPI $out/scrapers/ShokoAPI
    cp -r $src/scrapers/py_common $out/scrapers/ShokoAPI/py_common
    cp -f ${replaceVars ./config.py.template { path = configJSON; }} $out/scrapers/ShokoAPI/config.py
  '';
}
