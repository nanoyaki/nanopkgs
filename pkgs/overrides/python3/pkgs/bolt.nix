# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  python3,
  python3Packages,

  _sources,
}:

python3Packages.buildPythonPackage {
  inherit (_sources.bolt) pname src;
  version = lib.removePrefix "v" _sources.bolt.version;
  pyproject = true;

  dependencies = with python3.pkgs; [
    beet
    mecha
  ];

  build-system = [ python3Packages.poetry-core ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    mainProgram = "bolt";
  };
}
