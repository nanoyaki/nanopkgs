# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  flaresolverr = prev.flaresolverr.overrideAttrs {
    inherit (final._sources.flaresolverr) pname src;
    version = final.lib.removePrefix "v" final._sources.flaresolverr.version;

    postPatch = ''
      substituteInPlace src/undetected_chromedriver/patcher.py \
        --replace-fail \
          "from packaging.version import Version as LooseVersion" \
          "from looseversion import LooseVersion"

      substituteInPlace src/utils.py \
        --replace-fail \
          'CHROME_EXE_PATH = None' \
          'CHROME_EXE_PATH = "${final.lib.getExe final.chromium}"' \
        --replace-fail \
          'PATCHED_DRIVER_PATH = None' \
          'PATCHED_DRIVER_PATH = "${final.lib.getExe final.undetected-chromedriver}"'
    '';
  };
}
