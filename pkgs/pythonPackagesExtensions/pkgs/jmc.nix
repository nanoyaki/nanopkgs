# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildPythonPackage,
  setuptools,

  nuitka,
  zstandard,
  ordered-set,

  _sources,
}:

buildPythonPackage {
  inherit (_sources.jmc) pname src;
  version = lib.removePrefix "v" _sources.jmc.version;
  pyproject = true;

  sourceRoot = "${_sources.jmc.src.name}/src";

  build-system = [ setuptools ];

  dependencies = [
    nuitka
    zstandard
    ordered-set
  ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    mainProgram = "jmc";
  };
}
