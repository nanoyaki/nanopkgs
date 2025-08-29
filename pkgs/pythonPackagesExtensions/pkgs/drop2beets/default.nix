# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildPythonPackage,
  poetry-core,

  beetsPackages,
  watchdog,

  _sources,
}:

let
  inherit (beetsPackages) beets-minimal;
in

buildPythonPackage {
  inherit (_sources.drop2beets) pname version src;
  pyproject = true;

  patches = [
    ./watchdog-version.patch
  ];

  nativeBuildInputs = [
    beets-minimal
    poetry-core
  ];
  dependencies = [ watchdog ];

  meta = {
    description = "Beets plug-in that imports singles as soon as they are dropped in a folder.";
    homepage = "https://github.com/martinkirch/drop2beets/";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ nanoyaki ];
    inherit (beets-minimal.meta) platforms;
  };
}
