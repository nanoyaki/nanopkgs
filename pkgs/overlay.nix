# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{ inputs, ... }:

let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs.lib)
    composeManyExtensions
    foldr
    splitString
    elemAt
    recursiveUpdate
    attrNames
    importJSON
    mapAttrs'
    nameValuePair
    recurseIntoAttrs
    ;
  inherit (builtins) readDir;

  overrides = map (override: import (./overrides + "/${override}")) (attrNames (readDir ./overrides));
in

{
  flake.overlays.default = composeManyExtensions (
    [
      (final: _: {
        # This code is absolutely terrible haha
        minecraft = foldr (
          filename: attrs:
          let
            sources = importJSON (../_modSources + "/${filename}");
            project = elemAt (splitString "." filename) 0;
          in
          recursiveUpdate attrs (
            recurseIntoAttrs (
              mapAttrs' (
                loader: gameVersions:
                nameValuePair loader (
                  recurseIntoAttrs (
                    mapAttrs' (
                      gameVersion: projectVersions:
                      let
                        mkVer = ver: if (builtins.match ''^[0-9].*'' ver) != null then "v${ver}" else ver;
                      in
                      nameValuePair (mkVer gameVersion) (
                        recurseIntoAttrs (
                          foldr (
                            projectVersion: attrs:
                            recursiveUpdate attrs {
                              ${project}."${mkVer projectVersion}" = final.fetchurl projectVersions.${projectVersion};
                            }
                          ) { } (attrNames projectVersions)
                        )
                      )
                    ) gameVersions
                  )
                )
              ) sources
            )
          )
        ) { } (attrNames (removeAttrs (readDir ../_modSources) [ "_projects.json" ]));
      })
      (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./by-name)
    ]
    ++ overrides
  );
}
