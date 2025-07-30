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
  inherit (_sources.beet) pname src;
  version = lib.removePrefix "v" _sources.beet.version;
  pyproject = true;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'nbtlib = "^1.12.1"' 'nbtlib = "^2.0.0"' \
      --replace-fail 'pathspec = "^0.11.2"' 'pathspec = "^0.12.0"' \
      --replace-fail 'poetry>=0.12' 'poetry-core' \
      --replace-fail 'poetry.masonry.api' 'poetry.core.masonry.api'

    substituteInPlace beet/library/data_pack.py \
      --replace-fail 'StructureFile.parse(fileobj).root' 'StructureFile.parse(fileobj)'
  '';

  dependencies = with python3.pkgs; [
    nbtlib
    pathspec
    pydantic
    click
    click-help-colors
    jinja2
    toml
    pyyaml
    pillow
    typing-extensions
  ];

  build-system = [ python3Packages.poetry-core ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
