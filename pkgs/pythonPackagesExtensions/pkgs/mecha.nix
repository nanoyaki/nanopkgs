# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildPythonPackage,
  poetry-core,

  beet,
  tokenstream,

  _sources,
}:

buildPythonPackage {
  inherit (_sources.mecha) pname src;
  version = lib.removePrefix "v" _sources.mecha.version;
  pyproject = true;

  dependencies = [
    beet
    tokenstream
  ];

  build-system = [ poetry-core ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
