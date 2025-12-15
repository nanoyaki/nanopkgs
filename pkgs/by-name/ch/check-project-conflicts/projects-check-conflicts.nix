# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
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
    if lib.isString projects then
      (if lib.hasInfix "," projects then lib.splitString "," projects else [ projects ])
    else if lib.isList projects then
      projects
    else
      builtins.throw "Projects must be a string of projects separated by commas or a list";

  input = map (project: minecraftPkgs.${loader}.${fromVersion}.${project}) parsedProjects;

  output = lib.lists.subtractLists (lib.attrNames minecraftPkgs.${loader}.${toVersion}) (
    lib.attrNames (
      lib.filterAttrs (_: deriv: lib.elem deriv input) minecraftPkgs.${loader}.${fromVersion}
    )
  );
in

if output == [ ] then
  "No conflicts found"
else
  "Following projects aren't ported to ${toVersion} yet: " + (lib.concatStringsSep ", " output)
