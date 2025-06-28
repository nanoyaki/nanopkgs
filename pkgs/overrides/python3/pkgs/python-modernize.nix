# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  python3Packages,

  _sources,
}:

python3Packages.buildPythonPackage {
  inherit (_sources.python-modernize) pname version src;
  pyproject = true;

  dependencies = with python3Packages; [
    fissix
    flit-core
  ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
