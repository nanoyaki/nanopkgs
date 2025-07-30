# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  python3Packages,

  _sources,
}:

python3Packages.buildPythonPackage {
  inherit (_sources.tokenstream) pname src;
  version = lib.removePrefix "v" _sources.tokenstream.version;
  pyproject = true;

  build-system = [ python3Packages.poetry-core ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
