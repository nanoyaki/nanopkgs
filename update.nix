# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  perSystem =
    {
      lib,
      pkgs,
      self',
      ...
    }:

    {
      apps.update = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs =
            (with pkgs; [
              nix
              nvfetcher
              git
              curl
              jq
              gnused
              gawk
              findutils
            ])
            ++ (with self'.packages; [
              nvchecker
            ]);
          text =
            let
              inherit (lib)
                importTOML
                attrNames
                remove
                map
                concatMapStrings
                concatStringsSep
                filter
                hasPrefix
                ;
              inherit (lib.lists) findFirstIndex;

              nvchecker = ''nvchecker -c nvchecker.toml -k "''${1:-/run/secrets/keys.toml}" -l debug --failures -e'';

              packages = attrNames (importTOML ./nvfetcher.toml);
              additionalVersions = remove "__config__" (attrNames (importTOML ./nvchecker.toml));

              conditionalUpdates =
                concatMapStrings
                  (
                    package:
                    "\ngrep -q \"${package}:\" /tmp/nvfetcher_changelog \\\n"
                    + (concatStringsSep " \\\n" (
                      map (additionalVersion: "\ \ && ${nvchecker} \"${additionalVersion}\"") (
                        filter (additionalVersion: hasPrefix "${package}." additionalVersion) additionalVersions
                      )
                    ))
                  )
                  (
                    filter (
                      package:
                      (findFirstIndex (additionalVersion: hasPrefix "${package}." additionalVersion) (
                        -1
                      ) additionalVersions) > -1
                    ) packages
                  );
            in
            ''
              set -e

              git stash

              nix flake update
              nvfetcher -l /tmp/nvfetcher_changelog -k "''${1:-/run/secrets/keys.toml}"
              ${conditionalUpdates}

              nvcmp -c nvchecker.toml | sed 's|->|→|g' > /tmp/nvchecker_changelog
              nvtake -c nvchecker.toml --all && rm '_versions/old_versions.json~' || :

              git add _sources _versions pkgs/**/deps.json flake.lock update*
              git commit -m "chore: Update $(date +"%d.%m.%y")

              $(cat /tmp/nvfetcher_changelog)
              $(cat /tmp/nvchecker_changelog)"

              git stash pop || echo "No stashed changes."

              exit 0
            '';
        };

        meta.description = ''
          Update pkgs
        '';
      };

      apps.update-pkg = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update-pkg";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            nix-shell "${pkgs.path}/maintainers/scripts/update.nix" \
              --arg include-overlays "[ (import $(pwd) { }).overlays.default ]" \
              --argstr path "$1"
          '';
        };

        meta.description = ''
          Run nixpkgs update scripts for overlayed packages
        '';
      };
    };
}
