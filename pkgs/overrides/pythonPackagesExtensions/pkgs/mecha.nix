# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  python3Packages,

  _sources,
}:

python3Packages.buildPythonPackage {
  inherit (_sources.mecha) pname src;
  version = lib.removePrefix "v" _sources.mecha.version;
  pyproject = true;

  dependencies = with python3Packages; [
    beet
    tokenstream
  ];

  build-system = [ python3Packages.poetry-core ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
