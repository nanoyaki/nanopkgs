# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{ self, ... }:

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
          runtimeInputs = with pkgs; [
            nix
            nix-update
            git
            git-lfs
          ];
          text =
            let
              inherit (lib)
                concatMapStrings
                attrNames
                filterAttrs
                isDerivation
                ;

              packageUpdates =
                concatMapStrings
                  (pkg: ''
                    nix-update -uF ${pkg} --system x86_64-linux
                  '')
                  (
                    attrNames (
                      filterAttrs (_: pkg: isDerivation pkg && pkg ? passthru.updateScript) self'.legacyPackages
                    )
                  );
            in
            ''
              set -ex

              git stash

              nix flake update
              ${packageUpdates}
              nix run .#update-mods

              nix fmt

              git add _modSources pkgs flake.lock update*
              git commit -m "chore: update packages"

              git stash pop || echo "No stashed changes."

              exit 0
            '';
        };

        meta.description = ''
          Update pkgs
        '';
      };

      apps.update-mods = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update-mods";
          runtimeInputs = [ pkgs.nix ];
          text = ''
            set -ex

            ${lib.concatMapStrings (project: ''
              nix run ${self}#mod-source -- "${project}"
              sleep 0.01
            '') (lib.importJSON ./_modSources/_projects.json)}
          '';
        };

        meta.description = ''
          Update pkgs
        '';
      };

      apps.mod-source = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "mod-source";
          runtimeInputs = with pkgs; [
            curl
            jq
          ];
          text = ''
            project="$1"
            # shellcheck disable=SC2016
            jq_query='
              [
                .[]
                | .version_number as $raw_version
                | .files[0] as $file
                | .loaders[] as $loader
                | .game_versions[] as $game_version
                | {
                  loader: $loader,
                  game_version: $game_version | gsub("\\."; "_"),
                  version: (
                    $raw_version
                    | gsub(
                      "(^v?|[\\-\\+]?"
                      + $game_version
                      + "[\\-\\+]?|[\\-\\+]?("
                      + "fabric|quilt|"
                      + $loader
                      + ")[\\-\\+]?)"
                      ; ""
                    )
                    | gsub("\\."; "_")
                  ),
                  file: {
                    name: ($file.filename | gsub(" "; "-")),
                    url: $file.url,
                    sha512: $file.hashes.sha512
                  }
                }
              ]
              | sort_by(
                .loader,
                (.game_version | test("^\\d+\\_\\d+")),
                (.game_version | [scan("\\d+") | tonumber]),
                (.version      | [scan("\\d+") | tonumber])
              )
              | reverse
              | reduce .[] as $i ({};
                .[$i.loader][$i.game_version].latest //= $i.file
                | .[$i.loader][$i.game_version][$i.version] = $i.file
              )
            '

            curl 'https://api.modrinth.com/v2/project/'"$project"'/version' \
              | jq -r "$jq_query" > "_modSources/$project.json"
          '';
          inheritPath = false;
        };

        meta.description = ''
          Convert a project versions query from modrinth into a mod source
        '';
      };
    };
}
