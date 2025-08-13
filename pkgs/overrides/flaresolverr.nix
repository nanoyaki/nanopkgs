# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  flaresolverr = prev.flaresolverr.overrideAttrs {
    inherit (final._sources.flaresolverr) pname src;
    version = final.lib.removePrefix "v" final._sources.flaresolverr.version;
  };
}
