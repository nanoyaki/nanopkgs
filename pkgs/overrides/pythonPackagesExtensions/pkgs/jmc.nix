# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  python3Packages,

  _sources,
}:

python3Packages.buildPythonPackage {
  inherit (_sources.jmc) pname src;
  version = lib.removePrefix "v" _sources.jmc.version;
  pyproject = true;

  sourceRoot = "${_sources.jmc.src.name}/src";

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
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
