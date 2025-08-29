# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,

  _sources,
}:

buildPythonPackage {
  inherit (_sources.tokenstream) pname src;
  version = lib.removePrefix "v" _sources.tokenstream.version;
  pyproject = true;

  build-system = [ poetry-core ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
