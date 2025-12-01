# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  stdenv,
  runCommand,
  libcosmicAppHook,
}:

runCommand "oldlibcosmicAppHook"
  {
    src = libcosmicAppHook;
    cargoLinkerVar = stdenv.hostPlatform.rust.cargoEnvVarTarget;
  }
  ''
    cp -a $src $out
    substituteAll $src/nix-support/setup-hook $out/nix-support/setup-hook
  ''
