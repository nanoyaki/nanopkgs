# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    _:

    {
      treefmt = {
        projectRootFile = "flake.nix";

        programs = {
          nixfmt.enable = true;
          jsonfmt.enable = true;
          yamlfmt.enable = true;
          yamlfmt.settings.formatter = {
            retain_line_breaks_single = true;
            max_line_length = 80;
            scan_folded_as_literal = true;
            trim_trailing_whitespace = true;
            eof_newline = true;
            force_array_style = "block";
          };
          toml-sort.enable = true;
          shfmt.enable = true;
          mdformat.enable = true;
        };

        settings.global.excludes = [
          "_modSources/**"
          "_sources/**"
          "_versions/**"
          "LICENSES/*"
          "**.license"
          ".envrc"
        ];
      };
    };
}
