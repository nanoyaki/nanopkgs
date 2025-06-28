# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  lidarr = prev.lidarr.overrideAttrs { inherit (final._sources.lidarr) pname version src; };
}
