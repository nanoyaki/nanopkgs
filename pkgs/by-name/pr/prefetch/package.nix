# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  writeShellApplication,
  nix,
}:

writeShellApplication {
  name = "prefetch";
  runtimeInputs = [ nix ];
  text = ''
    nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url "$@")"
  '';

  meta.description = "Simple shell script to make getting hashes for files easier";
}
