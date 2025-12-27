# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{ makeSetupHook }:

makeSetupHook {
  name = "shoko-plugin-install-hook.sh";
} ./shoko-plugin-post-install-hook.sh
