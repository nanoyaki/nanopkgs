# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  writeShellScriptBin,
  nix,
}:

writeShellScriptBin "check-project-conflicts" ''
  PROJECTS=""
  LOADER="fabric"
  FROM_VERSION=""
  TO_VERSION=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --projects)
        PROJECTS="$2"
        shift 2
        ;;
      --loader)
        LOADER="$2"
        shift 2
        ;;
      --fromVersion)
        FROM_VERSION="$2"
        shift 2
        ;;
      --toVersion)
        TO_VERSION="$2"
        shift 2
        ;;
      *)
        echo "Unknown argument: $1"
        exit 1
        ;;
    esac
  done

  if [[ -z "$FROM_VERSION" || -z "$TO_VERSION" ]]; then
    echo "Error: --fromVersion and --toVersion are required."
    echo "Usage: check-project-conflicts --projects \"axiom,balm\" --fromVersion v1_20 --toVersion v1_21"
    exit 1
  fi

  exec ${lib.getExe nix} \
    --extra-experimental-features 'pipe-operators nix-command flakes' \
    eval \
    --raw \
    --impure \
    --expr 'import ${./projects-check-conflicts.nix} {
      projects = "'"$PROJECTS"'";
      loader = "'"$LOADER"'";
      fromVersion = "'"$FROM_VERSION"'";
      toVersion = "'"$TO_VERSION"'";
    }'
''
