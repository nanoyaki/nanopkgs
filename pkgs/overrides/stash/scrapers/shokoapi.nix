# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  python313Packages,
  configPy ? "$src/scrapers/ShokoAPI/config.py",

  _sources,
}:

# configPy:
# SHOKO = {
#     "url":
#         "http://localhost:8111", #your shoko server url
#     "user":
#         "username",#your shoko server username
#     "pass":
#         "password" #your shoko server password
# }

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
    cp -f ${configPy} $out/scrapers/ShokoAPI/config.py
  '';
}
