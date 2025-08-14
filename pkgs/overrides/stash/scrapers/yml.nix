# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  name,
  stdenvNoCC,

  _sources,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = name;
  inherit (_sources.stash-scrapers) version src;

  pythonDeps = [ ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/scrapers/${finalAttrs.pname}
    cp -f $src/scrapers/${finalAttrs.pname}.yml $out/scrapers/${finalAttrs.pname}/${finalAttrs.pname}.yml

    runHook postInstall
  '';
})
