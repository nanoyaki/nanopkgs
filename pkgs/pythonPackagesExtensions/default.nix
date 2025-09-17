# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev:

let
  inherit (final.lib)
    map
    attrNames
    composeManyExtensions
    ;
  inherit (builtins) readDir;

  overrides = map (override: import (./overrides + "/${override}")) (attrNames (readDir ./overrides));
in

{
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (_: _: {
        inherit (final) _sources _versions;
      })

      (import ./pkgs/top-level.nix)
    ]
    ++ overrides;

  # I don't know how to feel about this solution
  _nanoPythonPkgs =
    (prev.python3.override {
      packageOverrides = composeManyExtensions final.pythonPackagesExtensions;
    }).pkgs;

  beet = final._nanoPythonPkgs.toPythonApplication final._nanoPythonPkgs.beet;
  drop2beets = final._nanoPythonPkgs.toPythonApplication final._nanoPythonPkgs.drop2beets;
  python-modernize = final._nanoPythonPkgs.toPythonApplication final._nanoPythonPkgs.python-modernize;
  nvchecker = final._nanoPythonPkgs.toPythonApplication final._nanoPythonPkgs.nvchecker;
  jmc = final._nanoPythonPkgs.toPythonApplication final._nanoPythonPkgs.jmc;
}
