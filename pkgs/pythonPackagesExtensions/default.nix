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
  python3 = prev.python3.override {
    packageOverrides = composeManyExtensions final.pythonPackagesExtensions;
  };

  beet = final.python3.pkgs.toPythonApplication final.python3.pkgs.beet;
  drop2beets = final.python3.pkgs.toPythonApplication final.python3.pkgs.drop2beets;
  python-modernize = final.python3.pkgs.toPythonApplication final.python3.pkgs.python-modernize;
  nvchecker = final.python3.pkgs.toPythonApplication final.python3.pkgs.nvchecker;
  jmc = final.python3.pkgs.toPythonApplication final.python3.pkgs.jmc;
}
