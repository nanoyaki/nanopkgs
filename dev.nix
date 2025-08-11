# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{ inputs, ... }:

{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  perSystem =
    {
      lib,
      pkgs,
      self',
      config,
      ...
    }:

    let
      inherit (lib) mapAttrs' nameValuePair;
    in

    {
      pre-commit = {
        check.enable = true;
        settings = {
          hooks = {
            treefmt = {
              enable = true;
              packageOverrides.treefmt = config.treefmt.build.wrapper;
            };

            statix = {
              enable = true;
              settings.config =
                ((pkgs.formats.toml { }).generate "statix.toml" {
                  disabled = [ "repeated_keys" ];
                }).outPath;
            };
            flake-checker.enable = true;
            deadnix.enable = true;

            reuse.enable = true;
          };

          excludes = [
            "_sources.*"
            ''.*\.patch''
          ];
        };
      };

      devShells.default = config.pre-commit.devShell.overrideAttrs (prevAttrs: {
        buildInputs =
          (prevAttrs.buildInputs or [ ])
          ++ (with pkgs; [
            git
            nvfetcher
            jq
            prefetch-yarn-deps
          ])
          ++ [ self'.packages.nvchecker ];
      });

      checks = mapAttrs' (n: nameValuePair "devShell-${n}") self'.devShells;
    };
}
