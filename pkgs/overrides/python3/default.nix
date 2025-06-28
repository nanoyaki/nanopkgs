# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  python3 = prev.python3.override {
    packageOverrides =
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
      );
  };
  inherit (final.python3.pkgs) nvchecker python-modernize;
}
