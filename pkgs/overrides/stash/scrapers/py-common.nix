# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenvNoCC,
  stashDataDir ? "/var/lib/stash",

  _sources,
}:

stdenvNoCC.mkDerivation {
  pname = "py_common";
  inherit (_sources.stash-scrapers) src version;

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
}
