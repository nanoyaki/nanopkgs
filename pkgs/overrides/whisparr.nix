# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  whisparr = prev.whisparr.overrideAttrs { inherit (final._sources.whisparr) pname version src; };
}
