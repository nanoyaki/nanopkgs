# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  nvchecker = prev.nvchecker.overrideAttrs (prevAttrs: {
    patches = (prevAttrs.patches or [ ]) ++ [ ./custom-timeout.patch ];

    propagatedBuildInputs = (prevAttrs.propagatedBuildInputs or [ ]) ++ [ final.python.pkgs.jq ];
  });
}
