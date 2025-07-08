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
            debug="''${DEBUG_NVCHECKER:-}"

            package="$1"
            dir="$2"

            log="./update_$package.log"
            outLink="$(mktemp ./XXXXXX_out_link -u)"
            updateScript="$(mktemp ./XXXXXX_update_script.sh -u)"

            bash -c "$(cat << EOF
            set -xe

            nix build .#"''${package}".fetch-deps --out-link $outLink
            sed 's|/nix/store/[^/]*-source/'"''${dir}"'/'"''${package}"'/deps\.json|'"''${dir}"'/'"''${package}"'/deps.json|g' \
                "\$(readlink -f $outLink)" \
                > $updateScript
            sed 's|/nix/store/[^/]*-source/pkgs/by-name/'"''${package:0:2}"'/'"$package"'|'"$(pwd)/''${dir}"'/'"''${package}"'|g' $updateScript \
                > $updateScript.tmp \
                && mv $updateScript.tmp $updateScript
            chmod +x $updateScript
            $updateScript

            rm $outLink $updateScript
            EOF)" &> "$log"
            if [ -z "$debug" ]; then rm "$log"; fi

            nix hash convert --hash-algo sha256 --to sri "$(sha256sum "$dir/$package/deps.json" | awk '{ print $1 }')"
          '';
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
            nix
          ];
          checkPhase = "";
          text = ''
            debug="''${DEBUG_NVCHECKER:-}"

            package="$1"
            dir="$2"

            log="./update_$package.log"
            outLink="$(mktemp ./XXXXXX_out_link -u)"
            updateScript="$(mktemp ./XXXXXX_update_script.sh -u)"

            bash -c "$(cat << EOF
            set -xe

            nix build .#"''${package}".mitmCache.updateScript --out-link $outLink
            sed 's|/nix/store/[^/]*-source/'"''${dir}"'/'"''${package}"'/deps\.json|'"''${dir}"'/'"''${package}"'/deps.json|g' \
                "\$(readlink -f $outLink)" \
                > $updateScript
            sed 's|useBwrap="''${USE_BWRAP:-1}"|useBwrap=""|g' $updateScript \
                > $updateScript.tmp \
                && mv $updateScript.tmp $updateScript
            sed 's|/nix/store/[^/]*-source/pkgs/by-name/'"''${package:0:2}"'/'"$package"'|'"$(pwd)/''${dir}"'/'"''${package}"'|g' $updateScript \
                > $updateScript.tmp \
                && mv $updateScript.tmp $updateScript
            chmod +x $updateScript
            $updateScript

            rm $outLink $updateScript
            EOF)" &> "$log"
            if [ -z "$debug" ]; then rm "$log"; fi

            nix hash convert --hash-algo sha256 --to sri $(sha256sum "$dir/$package/deps.json" | awk '{ print $1 }')
          '';
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

            hash="$(prefetch-yarn-deps "$(nix eval --raw .\#"$package.src.outPath")/yarn.lock")"
            nix hash convert --hash-algo sha256 --to sri "$hash"
          '';
        };

        meta.description = ''
          Generate sri-hash for yarn deps of package
        '';
      };
    };
}
