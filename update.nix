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
                importJSON
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

              modrinthUpdates = concatMapStrings (project: ''
                nix run ${self}#mod-source -- "${project}"
                sleep 0.01
              '') (importJSON ./_modSources/_projects.json);
            in
            ''
              set -ex

              git stash

              nix flake update
              ${packageUpdates}
              ${modrinthUpdates}

              nix fmt

              git add _modSources pkgs flake.lock update*
              git commit -m "chore: Update $(date +"%d.%m.%y")"

              git stash pop || echo "No stashed changes."

              exit 0
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
              reduce .[] as $version ({};
                .[$version.loaders[0]] += (
                  $version.game_versions | reduce .[] as $game_version ({};
                    if $game_version | test("^\\d\\.\\d{1,2}(\\.\\d{1,2})?$") then
                      .[$game_version] = (
                        $version.files[0] | {url, sha512: .hashes.sha512, name: .filename}
                      )
                    else
                      .
                    end
                  )
                )
              ) | map_values(
                to_entries | sort_by(.key | split(".") | map(tonumber? // 0)) | reverse | from_entries
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
