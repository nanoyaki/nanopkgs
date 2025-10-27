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
          runtimeInputs =
            (with pkgs; [
              nix
              nvfetcher
              git
              git-lfs
              curl
              jq
              gnused
              gawk
              gnugrep
              findutils
              coreutils-full
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
                importJSON
                ;
              inherit (lib.lists) findFirstIndex;

              nvchecker = ''nvchecker -c nvchecker.toml -k "''${1:-./keys.toml}" -l debug --failures -e'';

              packages = attrNames (importTOML ./nvfetcher.toml);
              additionalVersions = remove "__config__" (attrNames (importTOML ./nvchecker.toml));

              conditionalUpdates =
                concatMapStrings
                  (
                    package:
                    "\ngrep -q \"${package}:\" /tmp/nvfetcher_changelog && (\\\n"
                    + (concatStringsSep " \\\n" (
                      map (additionalVersion: "${nvchecker} \"${additionalVersion}\";") (
                        filter (additionalVersion: hasPrefix "${package}." additionalVersion) additionalVersions
                      )
                    ))
                    + ")"
                  )
                  (
                    filter (
                      package:
                      (findFirstIndex (additionalVersion: hasPrefix "${package}." additionalVersion) (
                        -1
                      ) additionalVersions) > -1
                    ) packages
                  );

              modrinthUpdates = concatMapStrings (project: ''
                nix run ${self}#mod-source -- "${project}"
                sleep 0.01
              '') (importJSON ./_modSources/_projects.json);
            in
            ''
              set -ex

              [[ -n "$DONT_STASH" ]] || git stash

              nix flake update
              nvfetcher -l /tmp/nvfetcher_changelog -k "''${1:-./keys.toml}"
              ${conditionalUpdates}
              ${nvchecker} "inPlayerEpisodePreview.version"

              nvcmp -c nvchecker.toml | sed 's|->|→|g' > /tmp/nvchecker_changelog
              nvtake -c nvchecker.toml --all && (rm '_versions/old_versions.json~' || :)
              ${modrinthUpdates}

              nix fmt

              git add _modSources _sources _versions pkgs/**/deps.json flake.lock update*
              git commit -m "chore: Update $(date +"%d.%m.%y")

              $(cat /tmp/nvfetcher_changelog)
              $(cat /tmp/nvchecker_changelog)"

              git stash pop || echo "No stashed changes."

              exit 0
            '';
          inheritPath = false;
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
              --arg include-overlays "[ (import $(pwd)).overlays.default ]" \
              --argstr path "$1"
          '';
        };

        meta.description = ''
          Run nixpkgs update scripts for overlayed packages
        '';
      };

      apps.update-dotnet = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update-dotnet";
          runtimeInputs = with pkgs; [
            gnused
            gawk
            coreutils-full
            nix
          ];
          checkPhase = "";
          text = ''
            package="$1"
            dir="$2"

            outLink="$(mktemp ./XXXXXX_out_link -u)"
            updateScript="$(mktemp ./XXXXXX_update_script.sh -u)"

            nix build .#"''${package}".fetch-deps --out-link $outLink &> /dev/null
            sed 's|/nix/store/[^/]*-source/'"''${dir}"'/'"''${package}"'/deps\.json|'"''${dir}"'/'"''${package}"'/deps.json|g' \
                "$(readlink -f $outLink)" \
                > $updateScript
            sed 's|/nix/store/[^/]*-source/pkgs/by-name/'"''${package:0:2}"'/'"$package"'|'"$(pwd)/''${dir}"'/'"''${package}"'|g' $updateScript \
                > $updateScript.tmp \
                && mv $updateScript.tmp $updateScript
            chmod +x $updateScript
            $updateScript &> /dev/null

            rm $outLink $updateScript

            nix hash convert --hash-algo sha256 --to sri "$(sha256sum "$dir/$package/deps.json" | awk '{ print $1 }')"
          '';
          inheritPath = false;
        };

        meta.description = ''
          Update dotnet package and output the deps' sha256 hash
        '';
      };

      apps.update-gradle = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update-gradle";
          runtimeInputs = with pkgs; [
            gnused
            gawk
            coreutils-full
            nix
          ];
          checkPhase = "";
          text = ''
            package="$1"
            dir="$2"

            outLink="$(mktemp ./XXXXXX_out_link -u)"
            updateScript="$(mktemp ./XXXXXX_update_script.sh -u)"

            nix build .#"''${package}".mitmCache.updateScript --out-link $outLink &> /dev/null
            sed 's|/nix/store/[^/]*-source/'"''${dir}"'/'"''${package}"'/deps\.json|'"''${dir}"'/'"''${package}"'/deps.json|g' \
                "$(readlink -f $outLink)" \
                > $updateScript
            sed 's|useBwrap="''${USE_BWRAP:-1}"|useBwrap=""|g' $updateScript \
                > $updateScript.tmp \
                && mv $updateScript.tmp $updateScript
            sed 's|/nix/store/[^/]*-source/pkgs/by-name/'"''${package:0:2}"'/'"$package"'|'"$(pwd)/''${dir}"'/'"''${package}"'|g' $updateScript \
                > $updateScript.tmp \
                && mv $updateScript.tmp $updateScript
            chmod +x $updateScript
            $updateScript &> /dev/null

            rm $outLink $updateScript

            nix hash convert --hash-algo sha256 --to sri $(sha256sum "$dir/$package/deps.json" | awk '{ print $1 }')
          '';
          inheritPath = false;
        };

        meta.description = ''
          Update gradle package and output the deps' sha256 hash
        '';
      };

      apps.prefetch-yarn = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "prefetch-yarn";
          runtimeInputs = with pkgs; [
            prefetch-yarn-deps
            nix
          ];
          text = ''
            package="$1"

            nix build .\#"$package.src" &> /dev/null || :
            hash="$(prefetch-yarn-deps "$(nix eval --raw .\#"$package.src.outPath")/yarn.lock")"
            nix hash convert --hash-algo sha256 --to sri "$hash"
          '';
          inheritPath = false;
        };

        meta.description = ''
          Generate sri-hash for yarn deps of package
        '';
      };

      apps.prefetch-npm = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "prefetch-npm";
          runtimeInputs = with pkgs; [
            prefetch-npm-deps
            nix
          ];
          text = ''
            package="$1"

            nix build .\#"$package.src" &> /dev/null || :
            hash="$(prefetch-npm-deps "$(nix eval --raw .\#"$package.src.outPath")/package-lock.json")"
            nix hash convert --hash-algo sha256 --to sri "$hash"
          '';
          inheritPath = false;
        };

        meta.description = ''
          Generate sri-hash for npm deps of package
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
