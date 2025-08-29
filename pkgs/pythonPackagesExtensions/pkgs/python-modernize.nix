# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildPythonPackage,

  fissix,
  flit-core,

  _sources,
}:

buildPythonPackage {
  inherit (_sources.python-modernize) pname version src;
  pyproject = true;

  dependencies = [
    fissix
    flit-core
  ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
