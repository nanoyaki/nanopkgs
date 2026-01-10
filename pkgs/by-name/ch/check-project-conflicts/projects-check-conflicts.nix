# SPDX-FileCopyrightText: 2025-2026 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  projects ? [ ],
  loader ? "fabric",
  fromVersion,
  toVersion,
}:

let
  lib = import <nixpkgs/lib>;
  minecraftPkgs =
    (import (fetchGit {
      url = "https://git.theless.one/nanoyaki/nanopkgs.git";
      ref = "main";
    })).legacyPackages.${builtins.currentSystem}.minecraft;

  parsedProjects =
    (
      if lib.isString projects then
        (
          if lib.hasInfix "," projects then
            lib.splitString "," projects
          else
            (if lib.hasInfix "\n" projects then lib.splitString "\n" projects else [ projects ])
        )
      else if lib.isList projects then
        projects
      else
        throw "Projects must be a string of projects separated by commas, by new lines, or must be a list"
    )
    |> map lib.trim
    |> lib.filter (item: !(lib.hasInfix "#" item));

  input = map (project: minecraftPkgs.${loader}.${fromVersion}.${project}) parsedProjects;

  srcVersion = minecraftPkgs.${loader}.${fromVersion};
  destVersion = minecraftPkgs.${loader}.${toVersion};
  output =
    lib.filterAttrs (_: deriv: lib.elem deriv input) srcVersion
    |> lib.attrNames
    |> lib.lists.subtractLists (lib.attrNames destVersion);
in

if output == [ ] then
  "No conflicts found"
else
  "Following projects aren't ported to ${toVersion} yet: " + (lib.concatStringsSep ", " output)
