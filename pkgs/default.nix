# SPDX-FileCopyrightText: 2024 Sefa Eyeoglu <contact@scrumplex.net>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  self,
  ...
}:

{
  perSystem =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib)
        filterAttrs
        isDerivation
        makeScope
        mapAttrs'
        nameValuePair
        ;

      scope = makeScope pkgs.newScope (final: self.overlays.default (pkgs // final) pkgs);

      workingPackages = filterAttrs (_: pkg: !pkg.meta.broken) config.packages;
    in

    {
      legacyPackages = scope;

      packages = filterAttrs (
        _: pkg: (isDerivation pkg && lib.meta.availableOn pkgs.stdenv.hostPlatform pkg)
      ) scope;

      checks = mapAttrs' (n: nameValuePair "package-${n}") workingPackages;
    };
}
