# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
shokoPluginPostInstallHook() {
  mv $out/lib/$pname/* $out
  rmdir $out/{lib/$pname,lib}
}

postInstallHooks+=(shokoPluginPostInstallHook)
