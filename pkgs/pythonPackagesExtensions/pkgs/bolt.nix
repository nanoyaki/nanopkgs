# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildPythonPackage,
  poetry-core,

  beet,
  mecha,

  _sources,
}:

buildPythonPackage {
  inherit (_sources.bolt) pname src;
  version = lib.removePrefix "v" _sources.bolt.version;
  pyproject = true;

  dependencies = [
    beet
    mecha
  ];

  build-system = [ poetry-core ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    mainProgram = "bolt";
  };
}
