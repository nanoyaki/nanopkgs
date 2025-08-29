# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ (
      let
        inherit (final.lib)
          mapAttrs'
          map
          attrNames
          composeManyExtensions
          removeSuffix
          nameValuePair
          ;
        inherit (builtins) readDir;

        pkgs =
          _: _:
          mapAttrs' (
            package: _:
            nameValuePair (removeSuffix ".nix" package) (final.callPackage (./pkgs + "/${package}") { })
          ) (readDir ./pkgs);
        overrides = map (override: import (./overrides + "/${override}")) (attrNames (readDir ./overrides));
      in
      composeManyExtensions (
        [
          (_: _: {
            inherit (final) _sources _versions;
          })

          pkgs
        ]
        ++ overrides
      )
    );

  nvchecker = final.python3Packages.toPythonApplication final.python3Packages.nvchecker;
  python-modernize = final.python3Packages.toPythonApplication final.python3Packages.python-modernize;
}
