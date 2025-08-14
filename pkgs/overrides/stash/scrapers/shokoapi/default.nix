# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  python313Packages,
  replaceVars,
  configJSON ? ./default.json,
  stashDataDir ? "/var/lib/stash",

  _sources,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ShokoAPI";
  inherit (_sources.stash-scrapers) src version;

  pythonDeps = [
    python313Packages.requests
  ];

  postPatch = ''
    substituteInPlace scrapers/py_common/config.py \
      --replace-fail 'configs[0]' 'Path("${stashDataDir}/${finalAttrs.pname}-config.ini").absolute()'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/scrapers/${finalAttrs.pname}
    cp -r scrapers/${finalAttrs.pname} $out/scrapers/${finalAttrs.pname}
    cp -r scrapers/py_common $out/scrapers/${finalAttrs.pname}/py_common
    cp -f ${
      replaceVars ./config.py.template { path = configJSON; }
    } $out/scrapers/${finalAttrs.pname}/config.py

    runHook postInstall
  '';
})
